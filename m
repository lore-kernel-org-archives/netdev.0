From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: [PATCH] adm8211: fix the possible pci cache line sizes inside
 switch-case
Date: Tue, 5 May 2015 22:48:51 +0100
Message-ID: <20150505214851.GA3013@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI cache line size value, stored in cline variable, was being
compared against decimal values written as hex literals. This patch
changes those literals to correct hex values. 

Please note that this patch is on top of
another code cleanup patch '[PATCH] adm8211: fix checkpatch errors for
indentation and new line around switch-case'.


Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
---
 drivers/net/wireless/adm8211.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 058fb4b..76c908f 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1101,10 +1101,10 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
 		case  0x8:
 			reg |= (0x1 << 14);
 			break;
-		case 0x16:
+		case 0x10:
 			reg |= (0x2 << 14);
 			break;
-		case 0x32:
+		case 0x20:
 			reg |= (0x3 << 14);
 			break;
 		default:
-- 
1.9.1
