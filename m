From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v4 1/2] printk: Add a DEPRECATED macro
Date: Mon, 23 Dec 2013 08:29:42 -0500
Message-ID: <1387805383-21500-2-git-send-email-nhorman@tuxdriver.com>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
 <1387805383-21500-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387805383-21500-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sctp has several points in its setsockopt path in which it issues deprecation
warnings.  It seems like it might be handy to macrotize such a warning so other
subsystems can use it easily

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: "David S. Miller" <davem@davemloft.net>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org

---
Change Notes:

v3)
* Convert to using a string prefix rather than a specific pr_ macro
---
 include/linux/printk.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index 6949258..26fb95c 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -88,6 +88,13 @@ struct va_format {
 #define HW_ERR		"[Hardware Error]: "
 
 /*
+ * DEPRECATED
+ * Add this to a message whenever you want to warn user space about the use
+ * of a deprecated aspect of an API so they can stop using it
+ */
+#define DEPRECATED	"[Deprecated]: "
+
+/*
  * Dummy printk for disabled debugging statements to use whilst maintaining
  * gcc's format and side-effect checking.
  */
-- 
1.8.3.1
