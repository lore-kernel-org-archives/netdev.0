From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for
	Kirkwood SoCs
Date: Fri, 24 May 2013 18:13:00 +0100
Message-ID: <20130524171300.GD18614@n2100.arm.linux.org.uk>
References: <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com> <20130522201607.GA18823@obsidianresearch.com> <20130523160111.GP31290@titan.lakedaemon.net> <20130523171112.GB31281@obsidianresearch.com> <20130523172339.GQ31290@titan.lakedaemon.net> <20130523175357.GB2821@obsidianresearch.com> <20130523184028.GU31290@titan.lakedaemon.net> <519E9ADA.3040204@gmail.com> <CACRpkdbsicPkPAiaQCOg2mQF2Ce2dg_K=BKqqx=FCdAH7Y+QBg@mail.gmail.com> <20130524170125.GX31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:57048 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab3EXRN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 13:13:56 -0400
Content-Disposition: inline
In-Reply-To: <20130524170125.GX31290@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 01:01:25PM -0400, Jason Cooper wrote:
> On Fri, May 24, 2013 at 01:03:25PM +0200, Linus Walleij wrote:
> > IMO: if you want to go down that road, what you really want is not
> > ever more expressible device trees, but real open firmware,
> > or ACPI or UEFI that can interpret and run bytecode as some
> > "bios" for you. With DT coming from OF maybe this is a natural
> > progression of things, but one has to realize when we reach the
> > point where what we really want is a bios. Then your time is
> > likely better spent with Tianocore or something than with the
> > kernel.
> 
> shudder.  I like embedded systems because the *don't* have a bios.

Then you're into scenarios like I have with my laptop, where - those
of you who check the nightly build results will have noticed - one
of my serial ports doesn't always exist.  That's because the ACPI data
in the BIOS is *wrong*.  It reports that it has been enabled when it
hasn't, and the disassembled byte code is at fault here.

The fix?  God knows.  As far as I'm concerned as a user, or even as an
OS developer, it's unfixable without getting the ACPI data structures
changed, and that's not something I can do.

Do you really want that on ARM?  Given the fiasco with the location of
the registers, are you sure you want to place more trust in that
direction?  Does it give you a warm fuzzy feeling to know that you
might have to work out some way to patch vendor supplied bytecode?
