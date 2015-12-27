From: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH 5/9] ipw2x00: sdhci-pci: use to_pci_dev()
Date: Sun, 27 Dec 2015 18:46:01 +0800
Message-ID: <896b7d080610c5417a2f09a3bf9d0e20636fcc52.1451211133.git.geliangtang@163.com>
References: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
In-Reply-To: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
References: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use to_pci_dev() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index 36818c7..121294f 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -3514,7 +3514,7 @@ static void ipw2100_msg_free(struct ipw2100_priv *priv)
 static ssize_t show_pci(struct device *d, struct device_attribute *attr,
 			char *buf)
 {
-	struct pci_dev *pci_dev = container_of(d, struct pci_dev, dev);
+	struct pci_dev *pci_dev = to_pci_dev(d);
 	char *out = buf;
 	int i, j;
 	u32 val;
-- 
2.5.0


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
