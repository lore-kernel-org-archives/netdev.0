From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [net-next] net: phy: marvell: Show complete link partner
 advertising
Date: Mon, 12 Jun 2017 17:10:16 +0100
Message-ID: <20170612161016.GD4902@n2100.armlinux.org.uk>
References: <20170612133237.E20945085BC@solo.franken.de>
 <a172b1f9-5141-6d53-1d96-bd028a0b0a23@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>, andrew@lunn.ch,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a172b1f9-5141-6d53-1d96-bd028a0b0a23@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2017 at 09:05:04AM -0700, Florian Fainelli wrote:
> On 06/12/2017 05:54 AM, Thomas Bogendoerfer wrote:
> > From: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> > 
> > Give back all modes advertised by the link partner. This change brings
> > the marvell phy driver in line with all other phy drivers.
> > 
> > Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> 
> I thought Russell had a similar patch but I can't find it applied in
> net-next, so:

I do, it has a subject line of "net: phy: fix marvell phy status reading"
and it's already been sent (first link).  DaveM said he applied it
(second link):

https://www.mail-archive.com/netdev@vger.kernel.org/msg170743.html
https://www.mail-archive.com/netdev@vger.kernel.org/msg171036.html

However, Thomas' patch removes slightly more code (I didn't spot that
"adv" is no longer used and we don't need to read the MII_ADVERTISE
register anymore.)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
