From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: setup right value for mdio hold time
Date: Sun, 29 Mar 2015 13:41:01 -0700 (PDT)
Message-ID: <20150329.134101.916097441015561162.davem@davemloft.net>
References: <1427450912-9793-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rmk+kernel@arm.linux.org.uk, Frank.Li@freescale.com,
	LW@KARO-electronics.de, fabio.estevam@freescale.com,
	kernel@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbC2UcS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 16:32:18 -0400
In-Reply-To: <1427450912-9793-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Fri, 27 Mar 2015 11:08:32 +0100

> The FEC modules used on i.MX28 and newer have a register to tune the =
MDIO
> output hold time that should be at least 10 ns. Up to now this value =
was not
> explicitly set and so resulted in less hold time if the fec clock was
> faster than 100 MHz.
>=20
> This was noticed on an i.MX28 machine that uses an input clock of ~15=
0
> Mhz which resulted in unreliable communication with a Marvell switch.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.
