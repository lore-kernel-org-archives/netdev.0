From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v2 net-next 3/4] ravb: Document binding for r8a7795
 SoC
Date: Fri, 11 Sep 2015 17:53:12 +0900
Message-ID: <20150911085311.GA8547@verge.net.au>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
 <1441936878-18290-4-git-send-email-horms+renesas@verge.net.au>
 <CAMuHMdWY+8Cv9ZnnzMcSYskFfArues8EnWgMiCMnQ16sN1TW_A@mail.gmail.com>
 <20150911081443.GD2835@verge.net.au>
 <CAMuHMdUYhUrT9vBtfPOdDWxHDq+ENhKvg9bmsHZsyyDJ=YtcLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdUYhUrT9vBtfPOdDWxHDq+ENhKvg9bmsHZsyyDJ=YtcLw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 10:41:31AM +0200, Geert Uytterhoeven wrote:
> Hi Simon,
> 
> On Fri, Sep 11, 2015 at 10:14 AM, Simon Horman <horms@verge.net.au> wrote:
> >> > @@ -18,6 +21,9 @@ Required properties:
> >> >  Optional properties:
> >> >  - interrupt-parent: the phandle for the interrupt controller that services
> >> >                     interrupts for this device.
> >> > +- interrupt-names: One entry per interrupt named "ch%u".
> >> > +                  For the R8A7795 SoC this property is mandatory,
> >> > +                  and "ch0" through "ch24" are mandatory.
> >>
> >> This suggests the single multiplexed interrupt on R-Car Gen2 can be called
> >> "ch0". Is that what you want? I know the driver doesn't care.
> >
> > No, its not what I intended.
> >
> > I think its reasonable to allow the multiplexed interrupt to be named,
> > but to what I wonder. The documentation seems to call the interrupt
> > "EthernetAVB", which isn't very exciting.
> 
> Perhaps "mux", like I did for rspi, cfr.
> Documentation/devicetree/bindings/spi/spi-rspi.txt:
> 
>   - interrupts       : A list of interrupt-specifiers, one for each entry in
>                        interrupt-names.
>                        If interrupt-names is not present, an interrupt specifier
>                        for a single muxed interrupt.
>   - interrupt-names  : A list of interrupt names. Should contain (if present):
>                          - "error" for SPEI,
>                          - "rx" for SPRI,
>                          - "tx" to SPTI,
>                          - "mux" for a single muxed interrupt.

Thanks for for that example. "mux" sounds good to me.

