From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wireless: ipw2x00: ipw2100.c:  Remove some unused functions
Date: Thu,  1 Jan 2015 16:32:53 +0100
Message-ID: <1420126373-27344-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@adurom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes some functions that are not used anywhere:
write_nic_dword_auto_inc() write_nic_auto_inc_address()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 6fabea0..fa88839 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -433,17 +433,6 @@ static inline void write_nic_byte(struct net_device *dev, u32 addr, u8 val)
 	write_register_byte(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
 }
 
-static inline void write_nic_auto_inc_address(struct net_device *dev, u32 addr)
-{
-	write_register(dev, IPW_REG_AUTOINCREMENT_ADDRESS,
-		       addr & IPW_REG_INDIRECT_ADDR_MASK);
-}
-
-static inline void write_nic_dword_auto_inc(struct net_device *dev, u32 val)
-{
-	write_register(dev, IPW_REG_AUTOINCREMENT_DATA, val);
-}
-
 static void write_nic_memory(struct net_device *dev, u32 addr, u32 len,
 				    const u8 * buf)
 {
-- 
1.7.10.4
