From: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] adm8211: fix checkpatch error for trailing statements on
 next line
Date: Tue, 5 May 2015 08:17:41 +0100
Message-ID: <20150505071741.GA2678@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: joe@perchescom
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes these checkpatch.pl errors:

ERROR: trailing statements should be on next line
ERROR: switch and case should be at the same indent

More specifically, the fix has been applied to the five occurances of the errors listed below.

ERROR: trailing statements should be on next line
#1101: FILE: drivers/net/wireless/adm8211.c:1101:
+		case  0x8: reg |= (0x1 << 14);

ERROR: trailing statements should be on next line
#1103: FILE: drivers/net/wireless/adm8211.c:1103:
+		case 0x16: reg |= (0x2 << 14);

ERROR: trailing statements should be on next line
#1105: FILE: drivers/net/wireless/adm8211.c:1105:
+		case 0x32: reg |= (0x3 << 14);

ERROR: trailing statements should be on next line
#1107: FILE: drivers/net/wireless/adm8211.c:1107:
+		default: reg |= (0x0 << 14);

ERROR: switch and case should be at the same indent
#1100: FILE: adm8211.c:1100:
+		switch (cline) {
[...]
+		  default:


Signed-off-by: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f07a618..79e4e5f 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
