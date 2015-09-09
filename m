From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 10/13] Hide USE_WCACHING behind #ifdef __KERNEL__
Date: Wed,  9 Sep 2015 14:08:19 -0700
Message-ID: <1441832902-28993-11-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3@gmail.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: hpa@zytor.com
Cc: mingo@redhat.com
Cc: plagnioj@jcrosoft.com
Cc: jikos@kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: tglx@linutronix.de
Cc: tomi.valkeinen@ti.com
Cc: x86@kernel.org
Cc: Palmer Dabbelt <palmer@dabbelt.com>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't think this was ever intended to be exposed to userspace.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/linux/pktcdvd.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/pktcdvd.h b/include/uapi/linux/pktcdvd.h
index 2640b9d4e243..e2a49bfee74e 100644
--- a/include/uapi/linux/pktcdvd.h
+++ b/include/uapi/linux/pktcdvd.h
@@ -33,11 +33,13 @@
  * able to successfully recover with this option (drive will return good
  * status as soon as the cdb is validated).
  */
+#ifdef __KERNEL__
 #if defined(CONFIG_CDROM_PKTCDVD_WCACHE)
 #define USE_WCACHING		1
 #else
 #define USE_WCACHING		0
 #endif
+#endif /* __KERNEL__ */
 
 /*
  * No user-servicable parts beyond this point ->
-- 
2.4.6
