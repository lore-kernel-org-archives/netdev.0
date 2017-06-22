From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy: micrel: configure intterupts after autoneg
 workaround
Date: Thu, 22 Jun 2017 11:07:14 -0400 (EDT)
Message-ID: <20170622.110714.778230283978724620.davem@davemloft.net>
References: <1497980891-10495-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: zach.brown@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497980891-10495-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@ni.com>
Date: Tue, 20 Jun 2017 12:48:11 -0500

> The commit ("net/phy: micrel: Add workaround for bad autoneg") fixes an
> autoneg failure case by resetting the hardware. This turns off
> intterupts. Things will work themselves out if the phy polls, as it will
> figure out it's state during a poll. However if the phy uses only
> intterupts, the phy will stall, since interrupts are off. This patch
> fixes the issue by calling config_intr after resetting the phy.
> 
> Fixes: d2fd719bcb0e ("net/phy: micrel: Add workaround for bad autoneg ")
> Signed-off-by: Zach Brown <zach.brown@ni.com>

Applied and queued up for -stable.
