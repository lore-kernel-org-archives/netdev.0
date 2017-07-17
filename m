From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect ops
Date: Mon, 17 Jul 2017 23:04:05 +0200
Message-ID: <20170717210405.GC11719@lunn.ch>
References: <20170717170346.19555-12-vivien.didelot@savoirfairelinux.com>
 <20170717192734.GD9363@lunn.ch>
 <87bmoiuae3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170717.134549.2101398770863549187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717.134549.2101398770863549187.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 01:45:49PM -0700, David Miller wrote:
> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Mon, 17 Jul 2017 15:32:52 -0400
> 
> > Hi Andrew,
> > 
> > Andrew Lunn <andrew@lunn.ch> writes:
> > 
> >> I never liked this. I think it is architecturally wrong for the switch
> >> to be poking around in the PHY. It should ask the PHY driver. This is
> >> especially true for external PHYs which might not be a Marvell PHY.
> > 
> > I share the same concern. However this patch is just isolating the
> > existing code so that we get rid of the last caps and flags and stop
> > writing (without reading them first) arbitrary registers.
> > 
> > Once this portion is moved to the PHY driver, one can remove it from
> > mv88e6xxx.
> 
> Seems a reasonable plan of action.
> 
> Andrew, do you agree?

Hi David

I just fear it will not get fixed, just put into a corner to
fester. Having to fix it properly before these patches are merged
provides some incentive.

	 Andrew
