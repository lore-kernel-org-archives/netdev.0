From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
 consolidate fec_get_mac
Date: Wed, 29 Dec 2010 19:58:09 +0800
Message-ID: <20101229115808.GF19347@freescale.com>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com>
 <1293548155-16328-4-git-send-email-shawn.guo@freescale.com>
 <20101229065329.GB31010@jasper.tkos.co.il>
 <20101229100520.GB19347@freescale.com>
 <20101229103138.GT14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, <davem@davemloft.net>,
	<gerg@snapgear.com>, <eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:18253
	"EHLO VA3EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751760Ab0L2L4T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 06:56:19 -0500
Received: from mail71-va3 (localhost.localdomain [127.0.0.1])	by
 mail71-va3-R.bigfish.com (Postfix) with ESMTP id 5185B16F02C0	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 11:56:16 +0000 (UTC)
Received: from VA3EHSMHS007.bigfish.com (unknown [10.7.14.241])	by
 mail71-va3.bigfish.com (Postfix) with ESMTP id 20FD4147804F	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 11:56:16 +0000 (UTC)
Received: from az33smr02.freescale.net (az33smr02.freescale.net
 [10.64.34.200])	by az33egw01.freescale.net (8.14.3/8.14.3) with ESMTP id
 oBTBu3nU027197	for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 04:56:03 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu.ap.freescale.net [10.192.242.196])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id oBTBu21C013986	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 05:56:02 -0600 (CST)
Content-Disposition: inline
In-Reply-To: <20101229103138.GT14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Wed, Dec 29, 2010 at 11:31:38AM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Shawn,
>=20
> On Wed, Dec 29, 2010 at 06:05:21PM +0800, Shawn Guo wrote:
> > On Wed, Dec 29, 2010 at 08:53:30AM +0200, Baruch Siach wrote:
> > > Hi Shawn,
> > > In the case of dual MAC that you later add support for, the addre=
ss which one=20
> > > is being set? Is there a way to set both in kernel command line?
> > >=20
> > The fec0 gets fec_mac and fec1 gets fec_mac + 1. The following code
> > in function fec_get_mac takes care of it.
> >=20
> > 	/* Adjust MAC if using default MAC address */
> default MAC address means the address passed via cmdline?  Sounds
> confusing to me.
Will change the comment and fec_mac_default name to address
the concern.

>=20
> > 	if (iap =3D=3D fec_mac_default)
> > 		dev->dev_addr[ETH_ALEN-1] =3D fec_mac_default[ETH_ALEN-1] + fep->=
pdev->id;
> Can this overflow?  (I didn't check the code, so my concern might be
> completely stupid here.)
No. dev->dev_addr points to netdev_hw_addr->addr, which is a 32 bytes a=
rray.

--=20
Regards,
Shawn

