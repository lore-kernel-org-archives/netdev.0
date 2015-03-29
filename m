From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: make use of 4th parameter to
 devm_gpiod_get_index
Date: Sun, 29 Mar 2015 13:06:19 -0700 (PDT)
Message-ID: <20150329.130619.1197506503984550895.davem@davemloft.net>
References: <1427405168-28578-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nico@fluxnic.net, linus.walleij@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, kernel@pengutronix.de, acourbot@nvidia.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbC2T5l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:57:41 -0400
In-Reply-To: <1427405168-28578-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu, 26 Mar 2015 22:26:08 +0100

> Since 39b2bbe3d715 (gpio: add flags argument to gpiod_get*() function=
s)
> which appeared in v3.17-rc1, the gpiod_get* functions take an additio=
nal
> parameter that allows to specify direction and initial value for outp=
ut.
> Simplify accordingly.
>=20
> Moreover use devm_gpiod_get_index_optional for still simpler handling=
=2E
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied to net-next, thanks.
