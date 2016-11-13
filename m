From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Module parameter for opt-in of ASPM
Date: Sat, 12 Nov 2016 21:02:24 -0500 (EST)
Message-ID: <20161112.210224.1889131711533608896.davem@davemloft.net>
References: <20161103233306.GA9368@ASUS-Bernd.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: kastbernd@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103233306.GA9368@ASUS-Bernd.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kast Bernd <kastbernd@gmx.de>
Date: Fri, 4 Nov 2016 00:33:06 +0100

> This patch adds a module parameter in order to activate ASPM. By that
> the CPU can enter deep sleep modes (PC6) and power consumption can be
> reduced (for example from 13W to 8W on my notebook with a Haswell CPU).
> Basically, it reapplies d64ec841517a25f6d468bde9f67e5b4cffdc67c7, which
> was reverted due to delayed link status detection and increased boot
> times on some systems. These bugs are avoided by two actions:
>         1) ASPM is turned off by default to avoid any problems with the
> 	default	configuration.
>         2) Flags for ASPM and clock request are set after ephy_init,
> 	which wasn't respected on the previous patch. Thus ASPM with
> 	this patch could work even with previously failing systems.

This feels like grasping at straws.

If you feel you've corrected a flaw in the previous ASPM
support, then let's reinstate it unconditionally without
some module parameter.

We'll never find out if you actually did fix ASPM support
sufficiently if it's off by default.

Only experts like you will ever enable the option.  It's
usage will be minimal, and therefore the benefits will not
be sufficient to justify these changes in the first place.
