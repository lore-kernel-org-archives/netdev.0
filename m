From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Wed, 12 Jan 2011 08:42:25 +0100
Message-ID: <20110112074225.GY24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
 <20110111102717.GG26617@pengutronix.de>
 <4D2C4BEC.1030003@snapgear.com>
 <20110111130749.GQ24920@pengutronix.de>
 <4D2C5A55.7050502@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: baruch@tkos.co.il, B32542@freescale.com, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>, jamie@shareable.org,
	w.sang@pengutronix.de, r64343@freescale.com,
	linux-arm-kernel@lists.infradead.org, eric@eukrea.com,
	bryan.wu@canonical.com, jamie@jamieiles.com, davem@davemloft.net,
	Shawn Guo <shawn.guo@freescale.com>, lw@karo-electronics.de
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42661 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab1ALHmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 02:42:35 -0500
Content-Disposition: inline
In-Reply-To: <4D2C5A55.7050502@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Tue, Jan 11, 2011 at 11:25:41PM +1000, Greg Ungerer wrote:
> On 11/01/11 23:07, Uwe Kleine-K=F6nig wrote:
> >On Tue, Jan 11, 2011 at 10:24:12PM +1000, Greg Ungerer wrote:
> >>On 11/01/11 20:27, Sascha Hauer wrote:
> >>>On Thu, Jan 06, 2011 at 03:13:13PM +0800, Shawn Guo wrote:
> >>>This option is used nowhere and should be removed. Certainly it do=
es not
> >>>have the effect of enabling the second ethernet controller.
> >>
> >>It does for a ColdFire platform...
> >>
> >>grep -r CONFIG_FEC2 *
> >>
> >>arch/m68knommu/configs/m5275evb_defconfig:CONFIG_FEC2=3Dy
> >>arch/m68knommu/platform/527x/config.c:#ifdef CONFIG_FEC2
> >>arch/m68knommu/platform/527x/config.c:#ifdef CONFIG_FEC2
> >IMHO Sascha's comment[1] applies here, too.
>=20
> I am not arguing that it doesn't :-)
>=20
> Simply that removing that config option and doing nothing
> else would not be the right thing to do.
>=20
> Regards
> Greg
>=20
>=20
> >And someone might want to do what he suggested soon or the patch
> >removing CONFIG_FEC2[2] needs to be commented accordingly.
note that davem took the patch removing CONFIG_FEC2 now.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
