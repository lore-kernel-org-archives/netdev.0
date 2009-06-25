From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 11/19] drivers/net/wireless: Use PCI_VDEVICE
Date: Wed, 24 Jun 2009 22:13:27 -0700
Message-ID: <10b896c1a1e1f65a4a342ee5aa3452ab8cb43dfb.1245906152.git.joe@perches.com>
References: <cover.1245906151.git.joe@perches.com>
Cc: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1245906151.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ipw2x00/ipw2200.c        |   10 +++++-----
 drivers/net/wireless/prism54/islpci_hotplug.c |    4 +---
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 44c29b3..d726b3c 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11436,11 +11436,11 @@ static struct pci_device_id card_ids[] = {
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2754, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2761, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2762, 0, 0, 0},
-	{PCI_VENDOR_ID_INTEL, 0x104f, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{PCI_VENDOR_ID_INTEL, 0x4220, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},	/* BG */
-	{PCI_VENDOR_ID_INTEL, 0x4221, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},	/* BG */
-	{PCI_VENDOR_ID_INTEL, 0x4223, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},	/* ABG */
-	{PCI_VENDOR_ID_INTEL, 0x4224, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},	/* ABG */
+	{PCI_VDEVICE(INTEL, 0x104f), 0},
+	{PCI_VDEVICE(INTEL, 0x4220), 0},	/* BG */
+	{PCI_VDEVICE(INTEL, 0x4221), 0},	/* BG */
+	{PCI_VDEVICE(INTEL, 0x4223), 0},	/* ABG */
+	{PCI_VDEVICE(INTEL, 0x4224), 0},	/* ABG */
 
 	/* required last entry */
 	{0,}
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index 3087672..83d3662 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -49,9 +49,7 @@ static const struct pci_device_id prism54_id_tbl[] = {
 
 	/* 3COM 3CRWE154G72 Wireless LAN adapter */
 	{
-	 0x10b7, 0x6001,
-	 PCI_ANY_ID, PCI_ANY_ID,
-	 0, 0, 0
+	 PCI_VDEVICE(3COM, 0x6001), 0
 	},
 
 	/* Intersil PRISM Indigo Wireless LAN adapter */
-- 
1.6.3.1.10.g659a0.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
