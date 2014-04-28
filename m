From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/4] dt: bindings: Typo s/clocks-names/clock-names/g
Date: Mon, 28 Apr 2014 12:42:13 +0100
Message-ID: <20140428114213.D81B5C40AAE@trevor.secretlab.ca>
References: <1398192025-31523-1-git-send-email-geert+renesas@glider.be>
	<1398440850.389.0.camel@linux-builds1>
Cc: Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org
To: Dinh Nguyen <dinguyen@altera.com>,
	Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398440850.389.0.camel@linux-builds1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Apr 2014 10:47:30 -0500, Dinh Nguyen <dinguyen@altera.com> wrote:
> On Tue, 2014-04-22 at 20:40 +0200, Geert Uytterhoeven wrote:
> > Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> > Cc: Dinh Nguyen <dinguyen@altera.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: netdev@vger.kernel.org
> > ---
> >  .../devicetree/bindings/net/socfpga-dwmac.txt      |    2 +-
> >  Documentation/devicetree/bindings/net/stmmac.txt   |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> > index 636f0ac4e223..2a60cd3e8d5d 100644
> > --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> > +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> > @@ -23,5 +23,5 @@ gmac0: ethernet@ff700000 {
> >  	interrupt-names = "macirq";
> >  	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> >  	clocks = <&emac_0_clk>;
> > -	clocks-names = "stmmaceth";
> > +	clock-names = "stmmaceth";
> >  };
> > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> > index 80c1fb8bfbb8..a2acd2b26baf 100644
> > --- a/Documentation/devicetree/bindings/net/stmmac.txt
> > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> > @@ -33,7 +33,7 @@ Optional properties:
> >  - max-frame-size: See ethernet.txt file in the same directory
> >  - clocks: If present, the first clock should be the GMAC main clock,
> >    further clocks may be specified in derived bindings.
> > -- clocks-names: One name for each entry in the clocks property, the
> > +- clock-names: One name for each entry in the clocks property, the
> >    first one should be "stmmaceth".
> >  
> >  Examples:
> 
> I've applied this patch to git.rocketboards.org/linux-socfpga-next.git
> next-dt.

I've already got it in my tree which is in linux-next and will be asking
Linus to pull shortly.

g.
