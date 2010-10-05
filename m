From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/phy: fix many "defined but unused" warnings
Date: Tue, 05 Oct 2010 00:36:02 -0700 (PDT)
Message-ID: <20101005.003602.57483854.davem@davemloft.net>
References: <1286185413-22924-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756044Ab0JEHfl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 03:35:41 -0400
In-Reply-To: <1286185413-22924-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon,  4 Oct 2010 11:43:32 +0200

> MODULE_DEVICE_TABLE only expdrivers/net/phy/bcm63xx.c:134: warning: '=
bcm63xx_tbl' defined but not usedands to something if it's compiled
> for a module.  So when building-in support for the phys, the
> mdio_device_id tables are unused.  Marking them with __maybe_unused
> fixes the following warnings:
>=20
> 	drivers/net/phy/bcm63xx.c:134: warning: 'bcm63xx_tbl' defined but no=
t used
> 	drivers/net/phy/broadcom.c:933: warning: 'broadcom_tbl' defined but =
not used
> 	drivers/net/phy/cicada.c:162: warning: 'cicada_tbl' defined but not =
used
> 	drivers/net/phy/davicom.c:222: warning: 'davicom_tbl' defined but no=
t used
> 	drivers/net/phy/et1011c.c:114: warning: 'et1011c_tbl' defined but no=
t used
> 	drivers/net/phy/icplus.c:137: warning: 'icplus_tbl' defined but not =
used
> 	drivers/net/phy/lxt.c:226: warning: 'lxt_tbl' defined but not used
> 	drivers/net/phy/marvell.c:724: warning: 'marvell_tbl' defined but no=
t used
> 	drivers/net/phy/micrel.c:234: warning: 'micrel_tbl' defined but not =
used
> 	drivers/net/phy/national.c:154: warning: 'ns_tbl' defined but not us=
ed
> 	drivers/net/phy/qsemi.c:141: warning: 'qs6612_tbl' defined but not u=
sed
> 	drivers/net/phy/realtek.c:82: warning: 'realtek_tbl' defined but not=
 used
> 	drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not used
> 	drivers/net/phy/ste10Xp.c:135: warning: 'ste10Xp_tbl' defined but no=
t used
> 	drivers/net/phy/vitesse.c:195: warning: 'vitesse_tbl' defined but no=
t used
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Unfortunate but necessary for now, so applied, thanks.

Maybe we can eventually put something into MODULE_DEVICE_TABLE to add a=
 nop-style
reference, enough to shut up the compiler but not actually compile the =
table into
the code.
