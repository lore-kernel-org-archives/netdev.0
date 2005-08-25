From: Pavel Machek <pavel@suse.cz>
Subject: [patch] ipw2200: remove trap and unused stuff
Date: Thu, 25 Aug 2005 13:05:57 +0200
Message-ID: <20050825110557.GA16960__29988.2856350907$1124968318$gmane$org@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>, jbenc@suse.cz,
        jbo@suse.cz
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This removes one trap for a programmer, few unused macros, and one
unused struct. Please apply,

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- clean-mm/drivers/net/wireless/ipw2200.c	2005-08-24 20:25:09.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2200.c	2005-08-25 12:50:19.000000000 +0200
@@ -4485,7 +4485,7 @@
 	IPW_DEBUG_INFO("RATE MASK: 0x%08X\n", priv->rates_mask);
 }
 #else
-#define ipw_debug_config(x) do {} while (0);
+#define ipw_debug_config(x) do {} while (0)
 #endif
 
 static inline void ipw_set_fixed_rate(struct ipw_priv *priv,
--- clean-mm/drivers/net/wireless/ipw2200.h	2005-08-24 20:25:09.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2200.h	2005-08-25 12:42:30.000000000 +0200
@@ -95,8 +75,6 @@
 };
 
 
-#define IPW_NORMAL                   0
-#define IPW_NOWAIT                   0
 #define IPW_WAIT                     (1<<0)
 #define IPW_QUIET                    (1<<1)
 #define IPW_ROAMING                  (1<<2)
@@ -202,7 +180,7 @@
 
 /* even if MAC WEP set (allows pre-encrypt) */
 #define DCT_FLAG_NO_WEP              0x20
-#define IPW_
+
 /* overwrite TSF field */
 #define DCT_FLAG_TSF_REQD                  0x40
 
@@ -535,12 +513,6 @@
 	u16 status;
 } __attribute__ ((packed));
 
-struct temperature
-{
-	s32 measured;
-	s32 active;
-} __attribute__ ((packed));
-
 struct notif_calibration {
 	u8 data[104];
 } __attribute__ ((packed));

-- 
if you have sharp zaurus hardware you don't need... you know my address
