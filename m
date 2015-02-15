From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: disable NAND-tree for
 KSZ8021,KSZ8031,KSZ8051,KSZ8081
Date: Sat, 14 Feb 2015 20:31:39 -0800 (PST)
Message-ID: <20150214.203139.1139744729261595659.davem@davemloft.net>
References: <1423859733-21456-1-git-send-email-sylvain.rochet@finsecur.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nicolas.ferre@atmel.com,
	alexandre.belloni@free-electrons.com, voice.shen@atmel.com,
	josh.wu@atmel.com, ludovic.desroches@atmel.com,
	boris.brezillon@free-electrons.com
To: sylvain.rochet@finsecur.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423859733-21456-1-git-send-email-sylvain.rochet@finsecur.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sylvain Rochet <sylvain.rochet@finsecur.com>
Date: Fri, 13 Feb 2015 21:35:33 +0100

> NAND-tree is used to check wiring between MAC and PHY using NAND gates
> on the PHY side, hence the name.
> 
> NAND-tree initial status is latched at reset by probing the IRQ pin.
> However some devices are sharing the PHY IRQ pin with other peripherals
> such as Atmel SAMA5D[34]x-EK boards when using the optional TM7000
> display module, therefore they are switching the PHY in NAND-tree test
> mode depending on the current IRQ line status at reset.
> 
> This patch ensure PHY is not in NAND-tree test mode for all Micrel PHYs
> using IRQ line as a NAND-tree toggle mode at reset.
> 
> Signed-off-by: Sylvain Rochet <sylvain.rochet@finsecur.com>
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>

Applied.
