From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC net-next v3 3/4] ravb: Document binding for r8a7795
 SoC
Date: Mon, 21 Sep 2015 09:27:54 +0900
Message-ID: <20150921002751.GA24857@verge.net.au>
References: <1442556203-657-1-git-send-email-horms+renesas@verge.net.au>
 <1442556203-657-4-git-send-email-horms+renesas@verge.net.au>
 <CAMuHMdUFMq1szvY=8twhzcM36zyBjDF1fnkNd2kw+s=qxXYVmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Magnus Damm <magnus.damm@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdUFMq1szvY=8twhzcM36zyBjDF1fnkNd2kw+s=qxXYVmg@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 18, 2015 at 09:27:11AM +0200, Geert Uytterhoeven wrote:
> On Fri, Sep 18, 2015 at 8:03 AM, Simon Horman
> <horms+renesas@verge.net.au> wrote:
> > From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >
> > This patch updates the ravb binding to support the r8a7795 SoC by:
> > - Adding a compat string for the new hardware
> > - Adding 25 named interrupts to binding for the new SoC;
> >   older SoCs continue to use a single multiplexed interrupt
> >
> > The example is also updated to reflect the r8a7795 as this is the
> > more complex case.
> >
> > Based on work by Kazuya Mizuguchi and others.
> >
> > Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
> 
> Modulo the minor nit below...
> 
> > --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> 
> > @@ -18,6 +22,12 @@ Required properties:
> >  Optional properties:
> >  - interrupt-parent: the phandle for the interrupt controller that services
> >                     interrupts for this device.
> > +- interrupt-names: A list of interrupt names.
> > +                  For the R8A7795 SoC this property is mandatory;
> > +                  it should include one entry per channel, named "ch%u",
> > +                  where %u is the channel number ranging from 0 to 24.
> > +                  For other SoCs this property is optional; if present
> > +                  is should contain "mux" for a single muxed interrupt.
> 
> it

Thanks, I will fix that.
