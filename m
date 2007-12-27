From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] compilation fix for
	drivers/net/wireless/libertas/debugfs.c (fixed signed-off)
Date: Thu, 27 Dec 2007 13:35:36 +0300
Message-ID: <20071227103536.GA2396@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, mchan@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp91-76-74-99.pppoe.mtu-net.ru ([91.76.74.99]:42915 "EHLO
	iris.sw.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751531AbXL0Kd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2007 05:33:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compilation fix. MAC_FMT is required for
drivers/net/wireless/libertas/debugfs.c

The problem has been introduced by the
commit 4b326fa2167d4ee2d722bff4e241fae299e32442
Author: Michael Chan <mchan@broadcom.com>
Date:   Mon Dec 24 21:28:09 2007 -0800

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7a1e011..2928586 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -129,6 +129,7 @@ extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 extern char *print_mac(char *buf, const unsigned char *addr);
 #define MAC_BUF_SIZE	18
 #define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
