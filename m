From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Tue, 11 Jan 2011 14:07:50 +0100
Message-ID: <20110111130749.GQ24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
 <20110111102717.GG26617@pengutronix.de>
 <4D2C4BEC.1030003@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>, B32542@freescale.com,
	netdev@vger.kernel.org, jamie@shareable.org, baruch@tkos.co.il,
	w.sang@pengutronix.de, r64343@freescale.com, eric@eukrea.com,
	bryan.wu@canonical.com, jamie@jamieiles.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41571 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144Ab1AKNH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 08:07:59 -0500
Content-Disposition: inline
In-Reply-To: <4D2C4BEC.1030003@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Tue, Jan 11, 2011 at 10:24:12PM +1000, Greg Ungerer wrote:
> On 11/01/11 20:27, Sascha Hauer wrote:
> >On Thu, Jan 06, 2011 at 03:13:13PM +0800, Shawn Guo wrote:
> >This option is used nowhere and should be removed. Certainly it does=
 not
> >have the effect of enabling the second ethernet controller.
>=20
> It does for a ColdFire platform...
>=20
> grep -r CONFIG_FEC2 *
>=20
> arch/m68knommu/configs/m5275evb_defconfig:CONFIG_FEC2=3Dy
> arch/m68knommu/platform/527x/config.c:#ifdef CONFIG_FEC2
> arch/m68knommu/platform/527x/config.c:#ifdef CONFIG_FEC2
IMHO Sascha's comment[1] applies here, too.

And someone might want to do what he suggested soon or the patch
removing CONFIG_FEC2[2] needs to be commented accordingly.

Best regards
Uwe

[1] http://thread.gmane.org/gmane.linux.network/182929/focus=3D183378
[2] http://mid.gmane.org/1294747672-4433-1-git-send-email-shawn.guo@fre=
escale.com

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
