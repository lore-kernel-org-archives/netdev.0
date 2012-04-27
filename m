From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 11:08:31 +0200
Message-ID: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

User lautriv asked for belkin N-1 WLAN device support on IRC.

Further informations from lautriv:
* marvell 80W8031, card-id 11ab:2a02
* Debian/sid 3.2.x

On [1] I found a report by Jim Cromie concerning same PCI device-id:

00:0e.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
88W8361 [TopDog] 802.11n Wireless [11ab:2a02] (rev 03)
	Subsystem: Marvell Technology Group Ltd. 88W8361 [TopDog] 802.11n Wireless [11ab:2a02]

So, let's add 0x2a02 to PCI device table.

[1] http://www.spinics.net/lists/newbies/msg46601.html

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/mwl8k.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b48674b..16f0a9a 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5264,6 +5264,7 @@ MODULE_FIRMWARE("mwl8k/fmimage_8366.fw");
 MODULE_FIRMWARE(MWL8K_8366_AP_FW(MWL8K_8366_AP_FW_API));
 
 static DEFINE_PCI_DEVICE_TABLE(mwl8k_pci_id_table) = {
+	{ PCI_VDEVICE(MARVELL, 0x2a02), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a0a), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a0c), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a24), .driver_data = MWL8363, },
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
