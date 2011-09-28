From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 2/3] sh: modify prototype in sh_eth.h
Date: Wed, 28 Sep 2011 16:49:05 +0900
Message-ID: <4E82D171.6060200@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>, netdev@vger.kernel.org
To: Paul Mundt <lethal@linux-sh.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 arch/sh/include/asm/sh_eth.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/sh/include/asm/sh_eth.h b/arch/sh/include/asm/sh_eth.h
index 0f325da..2076acf 100644
--- a/arch/sh/include/asm/sh_eth.h
+++ b/arch/sh/include/asm/sh_eth.h
@@ -15,7 +15,7 @@ struct sh_eth_plat_data {
 	int edmac_endian;
 	int register_type;
 	phy_interface_t phy_interface;
-	void (*set_mdio_gate)(unsigned long addr);
+	void (*set_mdio_gate)(void *addr);

 	unsigned char mac_addr[6];
 	unsigned no_ether_link:1;
-- 
1.7.1

