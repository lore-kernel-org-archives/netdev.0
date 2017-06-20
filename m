From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net/phy: micrel: configure intterupts after autoneg
 workaround
Date: Tue, 20 Jun 2017 23:40:58 +0200
Message-ID: <20170620214058.GE12383@lunn.ch>
References: <1497980891-10495-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497980891-10495-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2017 at 12:48:11PM -0500, Zach Brown wrote:
> The commit ("net/phy: micrel: Add workaround for bad autoneg") fixes an
> autoneg failure case by resetting the hardware. This turns off
> intterupts. Things will work themselves out if the phy polls, as it will
> figure out it's state during a poll. However if the phy uses only
> intterupts, the phy will stall, since interrupts are off. This patch
> fixes the issue by calling config_intr after resetting the phy.
> 
> Fixes: d2fd719bcb0e ("net/phy: micrel: Add workaround for bad autoneg ")
> Signed-off-by: Zach Brown <zach.brown@ni.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
