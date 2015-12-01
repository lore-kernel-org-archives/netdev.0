From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: add R8A7791 support
Date: Tue, 1 Dec 2015 15:22:19 +0900
Message-ID: <20151201062218.GD16260@verge.net.au>
References: <6051623.qN4lqSyZKg@wasted.cogentembedded.com>
 <CAMuHMdWE_G2WqsGZEaa4Ck3zziTLGVPfaVdU2gbnLA5zWpmR1w@mail.gmail.com>
 <565B6AAD.8080205@cogentembedded.com>
 <20151130004207.GD3501@verge.net.au>
 <CAMuHMdV6frDHnsNo5+C3TPD-T8vgBZWkn722wCc5aCQ8+NDn+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdV6frDHnsNo5+C3TPD-T8vgBZWkn722wCc5aCQ8+NDn+A@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 09:08:57AM +0100, Geert Uytterhoeven wrote:
> Hi Simon,
> 
> On Mon, Nov 30, 2015 at 1:42 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Mon, Nov 30, 2015 at 12:14:21AM +0300, Sergei Shtylyov wrote:
> >> On 11/29/2015 10:26 PM, Geert Uytterhoeven wrote:
> >> >>Add support  for yet another ARM member of the R-Car family, R-Car M2, also
> >> >R-Car M2-W?
> >>
> >>    Right, forgot about the postfixes.
> >>
> >> >>known as R8A7791.
> >> >
> >> >There's also R-Car M2-N, aka R8A7793, but you probably know that ;-)
> >>
> >>    Will fix.
> >
> > I would prefer if we added generic gen2 and gen3 compat strings to the driver
> > and only documented new soc-specific compat strings.
> >
> > Actually by chance I was planning to up patches to do that and add compat
> > strings for the missing Gen2 boards. But I won't complain if you beat me to
> > it.
> 
> You're aware we have to keep the existing SoC-specific ones in the driver,
> for backwards compatibility?

Yes, I am aware of that.
