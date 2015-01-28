From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 0/3] Changes to cpsw and davinci_emac for getting MAC address
Date: Wed, 28 Jan 2015 11:33:03 -0800
Message-ID: <1422473586-18100-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here are a few patches to add common code for cpsw and davinci_emac for
getting the MAC address. Looks like we can also now add code to get the
MAC address on 3517 but in a slightly different way.

Regards,

Tony


Tony Lindgren (3):
  net: cpsw: Add a minimal cpsw-common module for shared code
  net: davinci_emac: Get device dm816x MAC address using the cpsw code
  net: davinci_emac: Get device MAC on 3517

 arch/arm/boot/dts/am3517.dtsi          |  1 +
 drivers/net/ethernet/ti/Makefile       |  3 ++
 drivers/net/ethernet/ti/cpsw-common.c  | 53 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c         | 35 ++-------------------
 drivers/net/ethernet/ti/cpsw.h         |  2 ++
 drivers/net/ethernet/ti/davinci_emac.c | 56 +++++++++++++++++++++++++++++++++-
 6 files changed, 116 insertions(+), 34 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw-common.c

-- 
2.1.4

