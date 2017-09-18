From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Fix mask value write on gmii2rgmii
 converter speed register
Date: Mon, 18 Sep 2017 16:34:08 -0700 (PDT)
Message-ID: <20170918.163408.207952584990169576.davem@davemloft.net>
References: <1505457118-3933-1-git-send-email-fahad.kunnathadi@dexceldesigns.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com, andrew@lunn.ch,
        appanad@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fahad.kunnathadi@dexceldesigns.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505457118-3933-1-git-send-email-fahad.kunnathadi@dexceldesigns.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
Date: Fri, 15 Sep 2017 12:01:58 +0530

> To clear Speed Selection in MDIO control register(0x10),
> ie, clear bits 6 and 13 to zero while keeping other bits same.
> Before AND operation,The Mask value has to be perform with bitwise NOT
> operation (ie, ~ operator)
> 
> This patch clears current speed selection before writing the
> new speed settings to gmii2rgmii converter
> 
> Fixes: f411a6160bd4 ("net: phy: Add gmiitorgmii converter support")
> 
> Signed-off-by: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied and queued up for -stable, thanks.
