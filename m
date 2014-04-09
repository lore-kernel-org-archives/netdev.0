From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 2/2] drivers:baycom_epp.c tabs
Date: Thu, 10 Apr 2014 00:25:21 +0100
Message-ID: <1397085921-13803-2-git-send-email-paulmcquad@gmail.com>
References: <1397085921-13803-1-git-send-email-paulmcquad@gmail.com>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: t.sailer@alumni.ethz.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397085921-13803-1-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ERROR: code indent should use tabs where possible
ERROR: space required after that ';' (ctx:VxV)

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 drivers/net/hamradio/baycom_epp.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 3daafec..5012ab5 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -54,7 +54,7 @@
 #include <linux/baycom.h>
 #include <linux/jiffies.h>
 #include <linux/random.h>
-#include <net/ax25.h> 
+#include <net/ax25.h>
 #include <linux/uaccess.h>
 
 /* --------------------------------------------------------------------- */
@@ -64,7 +64,7 @@
 
 /* --------------------------------------------------------------------- */
 
-static const char paranoia_str[] = KERN_ERR 
+static const char paranoia_str[] = KERN_ERR
 	"baycom_epp: bad magic number for hdlcdrv_state struct in routine %s\n";
 
 static const char bc_drvname[] = "baycom_epp";
@@ -169,7 +169,7 @@ static struct net_device *baycom_device[NR_PORTS];
 struct baycom_state {
 	int magic;
 
-        struct pardevice *pdev;
+	struct pardevice *pdev;
 	struct net_device *dev;
 	unsigned int work_running;
 	struct delayed_work run_work;
@@ -185,18 +185,18 @@ struct baycom_state {
 		unsigned int loopback;
 	} cfg;
 
-        struct hdlcdrv_channel_params ch_params;
+	struct hdlcdrv_channel_params ch_params;
 
-        struct {
+	struct {
 		unsigned int bitbuf, bitstream, numbits, state;
 		unsigned char *bufptr;
 		int bufcnt;
 		unsigned char buf[TXBUFFER_SIZE];
-        } hdlcrx;
+	} hdlcrx;
 
-        struct {
+	struct {
 		int calibrate;
-                int slotcnt;
+		int slotcnt;
 		int flags;
 		enum { tx_idle = 0, tx_keyup, tx_data, tx_tail } state;
 		unsigned char *bufptr;
@@ -246,9 +246,9 @@ struct baycom_state {
 #if 0
 static inline void append_crc_ccitt(unsigned char *buffer, int len)
 {
- 	unsigned int crc = 0xffff;
+	unsigned int crc = 0xffff;
 
-	for (;len>0;len--)
+	for ( ; len > 0; len--)
 		crc = (crc >> 8) ^ crc_ccitt_table[(crc ^ *buffer++) & 0xff];
 	crc ^= 0xffff;
 	*buffer++ = crc;
-- 
1.8.3.2
