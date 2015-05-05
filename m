From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: [PATCH 1/2] adm8211: fix checkpatch errors for indentation and new
 line
Date: Tue, 5 May 2015 23:40:07 +0100
Message-ID: <20150505224007.GA3655@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes these checkpatch.pl errors around a single switch-case block:

ERROR: switch and case should be at the same indent
ERROR: trailing statements should be on next line

More specifically, the fix has been applied to the five occurances of the errors listed below.

ERROR: switch and case should be at the same indent
#1100: FILE: adm8211.c:1100:
+		switch (cline) {
[...]
+		  default: reg |= (0x0 << 14);

ERROR: trailing statements should be on next line
#1101: FILE: adm8211.c:1101:
+		case  0x8: reg |= (0x1 << 14);

ERROR: trailing statements should be on next line
#1103: FILE: adm8211.c:1103:
+		case 0x16: reg |= (0x2 << 14);

ERROR: trailing statements should be on next line
#1105: FILE: adm8211.c:1105:
+		case 0x32: reg |= (0x3 << 14);

ERROR: trailing statements should be on next line
#1107: FILE: adm8211.c:1107:
+		  default: reg |= (0x0 << 14);


Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
---
 drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f07a618..058fb4b 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
 		pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
 
 		switch (cline) {
-		case  0x8: reg |= (0x1 << 14);
-			   break;
-		case 0x16: reg |= (0x2 << 14);
-			   break;
-		case 0x32: reg |= (0x3 << 14);
-			   break;
-		  default: reg |= (0x0 << 14);
-			   break;
+		case  0x8:
+			reg |= (0x1 << 14);
+			break;
+		case 0x16:
+			reg |= (0x2 << 14);
+			break;
+		case 0x32:
+			reg |= (0x3 << 14);
+			break;
+		default:
+			reg |= (0x0 << 14);
+			break;
 		}
 	}
 
-- 
1.9.1
