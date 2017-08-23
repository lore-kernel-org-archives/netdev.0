From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Wed, 23 Aug 2017 15:04:29 +0100
Message-ID: <20170823140429.GV20805@n2100.armlinux.org.uk>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <20170821125317.GS20805@n2100.armlinux.org.uk>
 <20170821150653.jmoogmxklkfbrzxg@sapphire.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:57648 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754034AbdHWOEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:04:42 -0400
Content-Disposition: inline
In-Reply-To: <20170821150653.jmoogmxklkfbrzxg@sapphire.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 06:06:53PM +0300, Baruch Siach wrote:
> Hi Russell,
> 
> On Mon, Aug 21, 2017 at 01:53:17PM +0100, Russell King - ARM Linux wrote:
> > Note that I didn't expect the SFP code to just get merged with very
> > little in the way of real in-depth review of things like:
> > 
> > * the way the SFP code works, and its structure
> > * analysis of the bindings checking that they're fit for everyone's
> >   purposes.
> 
> I was also surprised to see the "sff,sfp" compatible string with no ack from 
> DT maintainers. Hence this RFC.

I've been pushed into submitting the code for merging, and I hadn't
got around to writing the DT docs (thanks for doing that).  As I've
already said, I'm disappointed that the code didn't get more of a
review before it was merged - it seems Linux review is not what it
was, people care more about reviewing for spelling errors and style
than code structure and functionality, stating that "if we don't like
it we can always rework it" or similar.

It also seems that people believe that they can't make use of other
people's work until it gets merged into mainline kernels (which is
what has been behind the pressure of getting this merged.)

What isn't realised is that having other people use the code before
it gets merged allows design issues to be identified and resolved
when there is great flexibility available - for example, changing the
DT binding.  Once it's merged, changing DT bindings becomes harder,
especially if they need to be changed in an incompatible way.

I'm fed up about this, and way past caring about these details today
through.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
