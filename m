From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6.git
Date: Tue, 31 Oct 2006 22:48:35 -0500
Message-ID: <20061101034835.GC9309@tuxdriver.com>
References: <20061101034715.GB9309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:64521 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1423941AbWKAEAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 23:00:15 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061101034715.GB9309@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit ff584489917961599b9044584bb8ba6fd5d8f11b:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Christian Lamparter:
      wext: extend MLME support

Daniel Drake:
      zd1211rw: Add ID for ZyXEL G-220

 drivers/net/wireless/zd1211rw/zd_usb.c |    1 +
 include/linux/wireless.h               |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 005ca7a..5cc99b5 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -50,6 +50,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x1435, 0x0711), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3409), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0586, 0x3401), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index a50a013..7c269f4 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -546,6 +546,8 @@ #define IW_GENERIC_IE_MAX	1024
 /* MLME requests (SIOCSIWMLME / struct iw_mlme) */
 #define IW_MLME_DEAUTH		0
 #define IW_MLME_DISASSOC	1
+#define IW_MLME_AUTH		2
+#define IW_MLME_ASSOC		3
 
 /* SIOCSIWAUTH/SIOCGIWAUTH struct iw_param flags */
 #define IW_AUTH_INDEX		0x0FFF
-- 
John W. Linville
linville@tuxdriver.com
