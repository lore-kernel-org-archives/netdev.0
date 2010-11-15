From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 06/10] drivers/net/usb: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:29 -0800
Message-ID: <66a3d7996e4ce8a84610237e86adf4b15a48514a.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1289855436.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/pegasus.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 6710f093..ef36676 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -359,7 +359,7 @@ fail:
 
 static int mdio_read(struct net_device *dev, int phy_id, int loc)
 {
-	pegasus_t *pegasus = (pegasus_t *) netdev_priv(dev);
+	pegasus_t *pegasus = netdev_priv(dev);
 	u16 res;
 
 	read_mii_word(pegasus, phy_id, loc, &res);
@@ -397,7 +397,7 @@ fail:
 
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
 {
-	pegasus_t *pegasus = (pegasus_t *) netdev_priv(dev);
+	pegasus_t *pegasus = netdev_priv(dev);
 
 	write_mii_word(pegasus, phy_id, loc, val);
 }
-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
