From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Micrel PHY: Allow setting of config flag
 MICREL_PHY_50MHZ_CLK for KSZ8081/KSZ8091 PHY
Date: Thu, 13 Feb 2014 15:59:45 -0500 (EST)
Message-ID: <20140213.155945.598474865530817296.davem@davemloft.net>
References: <E1C9442006A9AE48A7A4B85E0D01C4D4753FB9@stwexdb.stww2k.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Georg.Waibel@sensor-technik.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E1C9442006A9AE48A7A4B85E0D01C4D4753FB9@stwexdb.stww2k.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Waibel Georg <Georg.Waibel@sensor-technik.de>
Date: Tue, 11 Feb 2014 08:28:50 +0000

> From fe6aad7bb4c61b3ccd14bf637025e87df05ca14c Mon Sep 17 00:00:00 2001
> From: Georg Waibel <georg.waibel@sensor-technik.de>
> Date: Tue, 11 Feb 2014 08:15:56 +0100
> Subject: [PATCH 1/1] Micrel PHY: Allow setting of config flag MICREL_PHY_50MHZ_CLK for KSZ8081/KSZ8091 PHY
> 
> The Micrel KSZ8081 and KSZ8091 PHYs support the RMII 50MHz mode. In this
> mode, the PHY can be driven by an external 50MHz clock source. This mode
> can be selected by the PHY device flag MICREL_PHY_50MHZ_CLK.
> The driver already supports this feature for the KSZ8051 PHY. Thus, the
> config_init function of this device can be used for the KSZ8081/8091 PHY
> too.
> 
> Signed-off-by: Georg Waibel <georg.waibel@sensor-technik.de>

The only thing in the entire tree which sets MICREL_PHY_50MHZ_CLK is
the apx4devkit_phy_fixup() in arch/arm/mach-mxs/mach-mxs.c, and it
is doing so for an 8051 PHY device.

If you plan to submit a patch which will set this flag in some other
situation, you can submit this patch at the same time.
