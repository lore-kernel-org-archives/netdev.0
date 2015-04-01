From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2] net: phy: at803x: simplify using
 devm_gpiod_get_optional and its 4th argument
Date: Wed, 1 Apr 2015 09:00:01 +0200
Message-ID: <20150401070001.GP17728@pengutronix.de>
References: <1427832525-6949-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20150331.192838.1922058179914527422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45044 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbbDAHDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 03:03:17 -0400
Content-Disposition: inline
In-Reply-To: <20150331.192838.1922058179914527422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 07:28:38PM -0400, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Tue, 31 Mar 2015 22:08:45 +0200
>=20
> > I still think assigning directly to priv->gpiod_reset would fine
> > because having the priv->gpiod_reset NULL is neither more nor less
> > right that ERR_PTR(-ESOMETHING).
>=20
> You really want to push my buttons don't you? :-/
>=20
> What if someone adds a new resource allocation after this thing and
> then adds an unwind path where something has to be done to the GPIOD
> as part of cleanup?
As I assume that v2 still addresses your concerns it would be ok for me
to not fully agree with you about defensive coding style.
What about you?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
