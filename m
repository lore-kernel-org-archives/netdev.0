From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next] net: mvpp2: phylink support
Date: Mon, 25 Sep 2017 15:06:10 +0200
Message-ID: <20170925130610.GE19364@kwain>
References: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
 <20170922110731.GG20805@n2100.armlinux.org.uk>
 <20170925095514.GA19364@kwain>
 <20170925104532.GN20805@n2100.armlinux.org.uk>
 <20170925115303.GC19364@kwain>
 <20170925121343.GO20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170925121343.GO20805@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 01:13:43PM +0100, Russell King - ARM Linux wrote:
> On Mon, Sep 25, 2017 at 01:53:03PM +0200, Antoine Tenart wrote:
> > On Mon, Sep 25, 2017 at 11:45:32AM +0100, Russell King - ARM Linux wrote:
> > > Can you describe what the GoP link IRQ is doing please?
> > 
> > In cases where there is no PHY connected to the MAC and no SFP cage is
> > used. One example is when a SOHO switch is connected directly to a
> > serdes lane. In such cases we still need to have a minimal link
> > management. The GoP link interrupt helps doing so as it raises when the
> > serdes is in sync and AN succeeded.
> 
> Isn't this just like a fixed link scenario, or an in-band
> autonegotiation scenario (both of which phylink supports natively)?
> 
> The situation on Clearfog with the 88E6176 switch is pretty similar -
> a switch connected directly via serdes to the MAC.  Currently, we
> configure stuff there as a fixed link, but in actual fact the 88E6176
> is configured to run the CPU facing port in 1000base-X mode, and with
> appropriate tweaks, switching phylink to 1000base-X mode also works.

Hmm, I think you're right, we should be able to represent the link
between the MAC and the switch as a fixed link. And when it's not fixed,
it could be done with in-band AN. I cannot test this myself but I've
asked someone who can to.

Antoine

-- 
Antoine Ténart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
