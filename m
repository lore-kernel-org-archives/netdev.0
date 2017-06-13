From: Tom Bogendoerfer <tsbogend@alpha.franken.de>
Subject: Re: [net-next] net: phy: marvell: Show complete link partner
 advertising
Date: Tue, 13 Jun 2017 10:32:27 +0200
Message-ID: <20170613083227.GA20254@alpha.franken.de>
References: <20170612133237.E20945085BC@solo.franken.de>
 <a172b1f9-5141-6d53-1d96-bd028a0b0a23@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, rmk+kernel@armlinux.org.uk
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
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> drivers/net/phy/lxt.c has a similar pattern that would be worth fixing too.

that's different and correct. The lpa value is not exported as lp_advertising,
but only used internal. Well the bug here is IMHO, that it doesn't
export lpa to lp_advertising at all as it's done in genphy_read_status().
And from a quick grep there are more phy drivers doing that...
I'll have a look later.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessarily a
good idea.                                                [ RFC1925, 2.3 ]
