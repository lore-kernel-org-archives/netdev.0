From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 11/13] Hide MAX_RAW_MINORS behind #ifdef __KERNEL__
Date: Wed,  9 Sep 2015 14:08:20 -0700
Message-ID: <1441832902-28993-12-git-send-email-palmer@dabbelt.com>
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

I don't think this was ever meant to be exposed to userspace.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/linux/raw.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/raw.h b/include/uapi/linux/raw.h
index 62d543e70603..6d8d87524ff2 100644
--- a/include/uapi/linux/raw.h
+++ b/include/uapi/linux/raw.h
@@ -13,6 +13,8 @@ struct raw_config_request
 	__u64	block_minor;
 };
 
+#ifdef __KERNEL__
 #define MAX_RAW_MINORS CONFIG_MAX_RAW_DEVS
+#endif
 
 #endif /* __LINUX_RAW_H */
-- 
2.4.6
