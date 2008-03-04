From: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Subject: [patch (for 2.6.25?) 2/2] bluetooth: CONWISE Technology based adapters with buggy SCO support (bugzilla #9027)
Date: Tue, 04 Mar 2008 14:58:07 -0800
Message-ID: <200803042258.m24Mw8UK001381@imap1.linux-foundation.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, sdiz-A7iEm+J7xfE@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: SDiZ <sdiz-A7iEm+J7xfE@public.gmane.org>

Fix the CONWISE Technology based adapters with buggy SCO support issue
(bugzilla #9027)

Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---

 drivers/bluetooth/hci_usb.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN drivers/bluetooth/hci_usb.c~bluetooth-conwise-technology-based-adapters-with-buggy-sco-support-bugzilla-9027 drivers/bluetooth/hci_usb.c
--- a/drivers/bluetooth/hci_usb.c~bluetooth-conwise-technology-based-adapters-with-buggy-sco-support-bugzilla-9027
+++ a/drivers/bluetooth/hci_usb.c
@@ -148,6 +148,9 @@ static struct usb_device_id blacklist_id
 	{ USB_DEVICE(0x0400, 0x0807), .driver_info = HCI_BROKEN_ISOC },
 	{ USB_DEVICE(0x0400, 0x080a), .driver_info = HCI_BROKEN_ISOC },
 
+	/* CONWISE Technology based adapters with buggy SCO support */
+	{ USB_DEVICE(0x0e5e, 0x6622), .driver_info = HCI_BROKEN_ISOC },
+
 	/* Belkin F8T012 and F8T013 devices */
 	{ USB_DEVICE(0x050d, 0x0012), .driver_info = HCI_RESET | HCI_WRONG_SCO_MTU },
 	{ USB_DEVICE(0x050d, 0x0013), .driver_info = HCI_RESET | HCI_WRONG_SCO_MTU },
_
--
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
