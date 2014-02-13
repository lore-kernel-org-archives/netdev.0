From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpsw: catch of_get_phy_mode failing and propagate
 error
Date: Thu, 13 Feb 2014 18:26:00 -0500 (EST)
Message-ID: <20140213.182600.1501969529994633708.davem@davemloft.net>
References: <1392244402-24823-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de, mugunthanvnm@ti.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbaBMX0D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:26:03 -0500
In-Reply-To: <1392244402-24823-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Wed, 12 Feb 2014 23:33:22 +0100

> It's wrong if the device tree doesn't provide a phy-mode property for
> the cpsw slaves as it is documented to be required in
> Documentation/devicetree/bindings/net/cpsw.txt.
>=20
> Anyhow it's nice to catch that problem, still more as it used to work
> without this property up to commit 388367a5a9fb (drivers: net: cpsw: =
use
> cpsw-phy-sel driver to configure phy mode) which is in v3.13-rc1.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied, thanks.
