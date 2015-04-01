From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: at803x: simplify using
 devm_gpiod_get_optional and its 4th argument
Date: Wed, 01 Apr 2015 12:14:19 -0400 (EDT)
Message-ID: <20150401.121419.1197252304341040447.davem@davemloft.net>
References: <1427832525-6949-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20150331.192838.1922058179914527422.davem@davemloft.net>
	<20150401070001.GP17728@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbbDAQOd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 12:14:33 -0400
In-Reply-To: <20150401070001.GP17728@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Wed, 1 Apr 2015 09:00:01 +0200

> On Tue, Mar 31, 2015 at 07:28:38PM -0400, David Miller wrote:
>> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Date: Tue, 31 Mar 2015 22:08:45 +0200
>>=20
>> > I still think assigning directly to priv->gpiod_reset would fine
>> > because having the priv->gpiod_reset NULL is neither more nor less
>> > right that ERR_PTR(-ESOMETHING).
>>=20
>> You really want to push my buttons don't you? :-/
>>=20
>> What if someone adds a new resource allocation after this thing and
>> then adds an unwind path where something has to be done to the GPIOD
>> as part of cleanup?
> As I assume that v2 still addresses your concerns it would be ok for =
me
> to not fully agree with you about defensive coding style.
> What about you?

The v2 patch is fine.

What isn't fine is that in the future you'll keep submitting patches th=
at
create dangerous situations, and I intend to keep rejecting them until
you stop putting error pointers into dynamically allocated memory.
