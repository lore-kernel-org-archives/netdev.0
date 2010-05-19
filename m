From: "Jean-Christophe Dubois" <jcd@tribudubois.net>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Wed, 19 May 2010 17:15:52 +0200
Message-ID: <201005191715.52905.jcd@tribudubois.net>
References: <cover.1260785451.git.baruch@tkos.co.il> <20091216063402.GA13160@jasper.tkos.co.il> <20100125112116.GF6724@jasper.tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@snapgear.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:46222 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832Ab0ESPQR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 11:16:17 -0400
In-Reply-To: <20100125112116.GF6724@jasper.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

le lundi 25 janvier 2010 Baruch Siach a =E9crit
> Hi Greg, netdev,
>=20
> On Wed, Dec 16, 2009 at 08:34:06AM +0200, Baruch Siach wrote:
> > On Wed, Dec 16, 2009 at 10:13:56AM +1000, Greg Ungerer wrote:
> > > Baruch Siach wrote:
> > > >On Tue, Dec 15, 2009 at 09:52:24PM +1000, Greg Ungerer wrote:
> > > >>On 12/15/2009 06:31 PM, Baruch Siach wrote:
> > > >>>+#ifndef CONFIG_M5272
> > > >>
> > > >>I would suggest making this conditional on FEC_MIIGSK_ENR.
> > > >>Although the CONFIG_M5272 is the only case here currently,
> > > >>that may change over the years. And using this here may not
> > > >>be obvious to the causual code reader, since the register
> > > >>offset definitions don't explicitly key on CONFIG_M5272.
> > > >
> > > >OK, I'll change this conditional.
> > > >
> > > >Can I take this as an Ack from you?
> > >=20
> > > With that conditional check changed, sure:
> > >=20
> > > Acked-by:  Greg Ungerer <gerg@uclinux.org>
> >=20
> > Thanks. The updated patch below.
>=20
> I'm really sorry to bug on this again, but since the platform code is
> already upstream the i.MX25 code doesn't build without this patch
> (include/linux/fec.h missing). So, someone please pick up this patch,
> preferably prior to .33.
>=20
> baruch

I am just wondering if somebody is going to pick up this patch=20
(http://patchwork.ozlabs.org/patch/41235/) so that it finds its way on=20
mainline.

The i.MX25 PDK platform (3DStack) has been broken for 2 kernel releases=
 (as=20
the actual code depend on this). Is there hope that this patch is picke=
d up by=20
somebody in order to get merged to main line someday?

Or is it not acceptable in this state for some reason?

Either the FEC changes need to be merged (possibly with some modificati=
on if=20
there are issues) or the part depending on it in the ARM tree need to b=
e=20
reverted. We should not stay in this non coherent state.

JC
