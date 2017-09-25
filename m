From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next] net: mvpp2: phylink support
Date: Mon, 25 Sep 2017 11:45:32 +0100
Message-ID: <20170925104532.GN20805@n2100.armlinux.org.uk>
References: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
 <20170922110731.GG20805@n2100.armlinux.org.uk>
 <20170925095514.GA19364@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170925095514.GA19364@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 11:55:14AM +0200, Antoine Tenart wrote:
> Hi Russell,
> 
> On Fri, Sep 22, 2017 at 12:07:31PM +0100, Russell King - ARM Linux wrote:
> > On Thu, Sep 21, 2017 at 03:45:22PM +0200, Antoine Tenart wrote:
> > > Convert the PPv2 driver to use phylink, which models the MAC to PHY
> > > link. The phylink support is made such a way the GoP link IRQ can still
> > > be used: the two modes are incompatible and the GoP link IRQ will be
> > > used if no PHY is described in the device tree. This is the same
> > > behaviour as before.
> > 
> > This makes no sense.  The point of phylink is to be able to support SFP
> > cages, and SFP cages do not have a PHY described in DT.  So, when you
> > want to use phylink because of SFP, you can't, because if you omit
> > the PHY the driver avoids using phylink.
> 
> Yes that's an issue. However we do need to support the GoP link IRQ
> which is also needed in some cases where there is no PHY (and when
> phylink cannot be used). What would you propose to differentiate those
> two cases: no PHY using phylink, and no PHY using the GoP link IRQ?

Can you describe what the GoP link IRQ is doing please?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
