From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net/phy: micrel: configure intterupts after autoneg
 workaround
Date: Tue, 20 Jun 2017 14:41:46 -0700
Message-ID: <ba3ef848-0f90-33f4-d204-d3a5dbe67f75@gmail.com>
References: <1497980891-10495-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497980891-10495-1-git-send-email-zach.brown@ni.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/2017 10:48 AM, Zach Brown wrote:
> The commit ("net/phy: micrel: Add workaround for bad autoneg") fixes an
> autoneg failure case by resetting the hardware. This turns off
> intterupts. Things will work themselves out if the phy polls, as it will
> figure out it's state during a poll. However if the phy uses only
> intterupts, the phy will stall, since interrupts are off. This patch
> fixes the issue by calling config_intr after resetting the phy.
> 
> Fixes: d2fd719bcb0e ("net/phy: micrel: Add workaround for bad autoneg ")
> Signed-off-by: Zach Brown <zach.brown@ni.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
