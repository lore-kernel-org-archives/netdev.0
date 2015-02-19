From: Alex W Slater <alex.slater.dev@gmail.com>
Subject: [PATCH] Replace "#include <asm/uaccess>" with "#include <linux/uaccess>"
Date: Thu, 19 Feb 2015 21:58:07 +0000
Message-ID: <1424383087-8058-1-git-send-email-alex.slater.dev@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, Alex W Slater <alex.slater.dev@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch.pl warning "Use #include <linux/uaccess.h> instead of <asm/uaccess.h>"

Signed-off-by: Alex W Slater <alex.slater.dev@gmail.com>
---
 net/ipv6/raw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dae7f1a..0d84b2c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -32,7 +32,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/skbuff.h>
 #include <linux/compat.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <asm/ioctls.h>
 
 #include <net/net_namespace.h>
-- 
1.7.10.4
