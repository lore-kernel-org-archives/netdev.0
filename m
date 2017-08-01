From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] net-next: mediatek: add support for
 ethernet on MT7622 SoC
Date: Tue, 01 Aug 2017 15:52:49 -0700 (PDT)
Message-ID: <20170801.155249.2173180679406605650.davem@davemloft.net>
References: <cover.1501494522.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1501494522.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Mon, 31 Jul 2017 18:05:07 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> Changes since v2:
> - update John's mail
> 
> Changes since v1:
> - add refinement for ethernet clock management
> - take out the code block for ESW, add it until ESW driver is actually introduced
> 
> The series adds the driver for ethernet controller found on MT7622 SoC.
> There are additions against with previous MT7623 SoC such as shared SGMII
> given for the dual GMACs and built-in 5-ports 10/100 embedded switch support
> (ESW). Thus more clocks consumers and SGMII hardware setup for the extra
> features are all introduced here and as for the support for ESW that would be
> planned to add in the separate patch integrating with DSA infrastructure
> in the future.
> 
> Currently testing successfully is done with those patches for the conditions
> such as GMAC2 with IP1001 PHY via RGMII and GMAC1/2 with RTL8211F PHY via SGMII.

Series applied, thank you.
