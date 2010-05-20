From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Thu, 20 May 2010 08:46:43 +0200
Message-ID: <20100520064642.GT31199@pengutronix.de>
References: <cover.1260785451.git.baruch@tkos.co.il> <20091216063402.GA13160@jasper.tkos.co.il> <20100125112116.GF6724@jasper.tkos.co.il> <201005191715.52905.jcd@tribudubois.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Baruch Siach <baruch@tkos.co.il>,
	Greg Ungerer <gerg@snapgear.com>,
	David Miller <davem@davemloft.net>
To: Jean-Christophe Dubois <jcd@tribudubois.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48271 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab0ETGqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 02:46:45 -0400
Content-Disposition: inline
In-Reply-To: <201005191715.52905.jcd@tribudubois.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 05:15:52PM +0200, Jean-Christophe Dubois wrote:
> le lundi 25 janvier 2010 Baruch Siach a =E9crit
> > Hi Greg, netdev,
> >=20
> > On Wed, Dec 16, 2009 at 08:34:06AM +0200, Baruch Siach wrote:
> > > On Wed, Dec 16, 2009 at 10:13:56AM +1000, Greg Ungerer wrote:
> > > > Baruch Siach wrote:
> > > > >On Tue, Dec 15, 2009 at 09:52:24PM +1000, Greg Ungerer wrote:
> > > > >>On 12/15/2009 06:31 PM, Baruch Siach wrote:
> > > > >>>+#ifndef CONFIG_M5272
> > > > >>
> > > > >>I would suggest making this conditional on FEC_MIIGSK_ENR.
> > > > >>Although the CONFIG_M5272 is the only case here currently,
> > > > >>that may change over the years. And using this here may not
> > > > >>be obvious to the causual code reader, since the register
> > > > >>offset definitions don't explicitly key on CONFIG_M5272.
> > > > >
> > > > >OK, I'll change this conditional.
> > > > >
> > > > >Can I take this as an Ack from you?
> > > >=20
> > > > With that conditional check changed, sure:
> > > >=20
> > > > Acked-by:  Greg Ungerer <gerg@uclinux.org>
> > >=20
> > > Thanks. The updated patch below.
> >=20
> > I'm really sorry to bug on this again, but since the platform code =
is
> > already upstream the i.MX25 code doesn't build without this patch
> > (include/linux/fec.h missing). So, someone please pick up this patc=
h,
> > preferably prior to .33.
> >=20
> > baruch
>=20
> I am just wondering if somebody is going to pick up this patch=20
> (http://patchwork.ozlabs.org/patch/41235/) so that it finds its way o=
n=20
> mainline.

I'm much in favour of this patch. David?

Sascha


--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
