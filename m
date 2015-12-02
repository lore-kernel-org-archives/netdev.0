From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2 net-next] ravb: Add fallback compatibility strings
Date: Wed, 2 Dec 2015 09:28:09 +0900
Message-ID: <20151202002809.GK27457@verge.net.au>
References: <1448955783-22806-1-git-send-email-horms+renesas@verge.net.au>
 <1448955783-22806-2-git-send-email-horms+renesas@verge.net.au>
 <CAMuHMdW_PagMbAqrvM-_-sJumhMPoYGobNF485Q1D+CRQ5j+bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54873 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128AbbLBA2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 19:28:12 -0500
Content-Disposition: inline
In-Reply-To: <CAMuHMdW_PagMbAqrvM-_-sJumhMPoYGobNF485Q1D+CRQ5j+bQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2015 at 09:42:52AM +0100, Geert Uytterhoeven wrote:
> On Tue, Dec 1, 2015 at 8:43 AM, Simon Horman <horms+renesas@verge.net.au> wrote:
> > Add fallback compatibility strings for R-Car Gen 2 & 3 SoC Families.
> > This is in keeping with the fallback scheme being adopted wherever
> > appropriate for drivers for Renesas SoCs.
> >
> > Also correct typo.
> >
> > Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> > ---
> >  Documentation/devicetree/bindings/net/renesas,ravb.txt | 11 +++++++++--
> >  drivers/net/ethernet/renesas/ravb_main.c               |  2 ++
> >  2 files changed, 11 insertions(+), 2 deletions(-)
> >
> > diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > index b486f3f5f6a3..115006325bff 100644
> > --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > @@ -1,12 +1,19 @@
> >  * Renesas Electronics Ethernet AVB
> >
> >  This file provides information on what the device node for the Ethernet AVB
> > -interface contains.
> > +interface.
> >
> >  Required properties:
> >  - compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
> >               "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
> >               "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
> > +             "renesas,etheravb-gen2" for generic R-Car Gen 2 compatible interface.
> > +             "renesas,etheravb-gen3" for generic R-Car Gen 3 compatible interface.
> > +
> 
> (Same comment, different audience)
> 
> Shouldn't that be "renesas,etheravb-rcar-gen" or "renesas,etheravb-rcar2"?
> 
> Else you'll be in trouble when Renesas starts focussing on airplanes
> (R-Plane Gen2), rockets (R-Rocket Gen2), or IoT (R-IoT Gen2).

Sure, lets go with:

renesas,etheravb-rcar-gen2 and renesas,etheravb-rcar-gen3.
