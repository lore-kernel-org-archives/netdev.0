From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: at803x: simplify using
 devm_gpiod_get_optional and its 4th argument
Date: Tue, 31 Mar 2015 19:28:38 -0400 (EDT)
Message-ID: <20150331.192838.1922058179914527422.davem@davemloft.net>
References: <1427832525-6949-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbbCaX2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 19:28:40 -0400
In-Reply-To: <1427832525-6949-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Tue, 31 Mar 2015 22:08:45 +0200

> I still think assigning directly to priv->gpiod_reset would fine
> because having the priv->gpiod_reset NULL is neither more nor less
> right that ERR_PTR(-ESOMETHING).

You really want to push my buttons don't you? :-/

What if someone adds a new resource allocation after this thing and
then adds an unwind path where something has to be done to the GPIOD
as part of cleanup?

What does your error pointer cause to happen to an unsuspecting person
creating such a change?

Why isn't this obvious to you as a good coding practice that is
future proof against any changes to this code?
