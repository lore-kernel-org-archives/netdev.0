From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: Re: [PATCH] Revert "net: fec: Ensure clocks are enabled while using
 mdio bus"
Date: Thu, 16 Jul 2015 09:15:34 +0200
Message-ID: <20150716071533.GA871@pqgruber.com>
References: <1437005044-13433-1-git-send-email-clemens.gruber@pqgruber.com>
 <20150715.173213.1635174183408438052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, B38611@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150715.173213.1635174183408438052.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2015 at 05:32:13PM -0700, David Miller wrote:
> From: Clemens Gruber <clemens.gruber@pqgruber.com>
> Date: Thu, 16 Jul 2015 02:04:04 +0200
> 
> > This reverts commit 6c3e921b18edca290099adfddde8a50236bf2d80.
> > 
> > The change did break ethernet support on the i.MX6Q and possibly also on
> > other platforms: The PHY was not detected anymore and eth0 was not found.
> > 
> > Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
> 
> This patch was already posted and in my queue (did you look?) and I applied
> it earlier today.

Oh, nice. Thanks! (Yes, before the commit. Must have overlapped, sorry!)
