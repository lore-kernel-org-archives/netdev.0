From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] netfilter: propogate return values
Date: Sat, 24 Jan 2004 22:23:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124222337.752a768a.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.

Thanks,
--
~Randy


From: Daniele Bellucci <bellucda@tiscali.it>


Patch apply cleany (against 2.6.1-mm3) and compile good to me.

Please Apply.

diff -puN net/ipv4/netfilter/ipt_CLASSIFY.c~ipt_register_target_retval net/ipv4/netfilter/ipt_CLASSIFY.c

diff -puN net/ipv4/netfilter/ipt_CLASSIFY.c~ipt_register_target_retval net/ipv4/netfilter/ipt_CLASSIFY.c


 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_CLASSIFY.c |    5 +----
 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_DSCP.c     |    5 +----
 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_ECN.c      |    5 +----
 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_LOG.c      |    5 +----
 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_MARK.c     |    5 +----
 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_REJECT.c   |    4 +---
 linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_TOS.c      |    5 +----
 7 files changed, 7 insertions(+), 27 deletions(-)

diff -puN net/ipv4/netfilter/ipt_CLASSIFY.c~ipt_register_target_retval net/ipv4/netfilter/ipt_CLASSIFY.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_CLASSIFY.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_CLASSIFY.c	2004-01-23 15:46:14.000000000 -0800
@@ -71,10 +71,7 @@ static struct ipt_target ipt_classify_re
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_classify_reg))
-		return -EINVAL;
-
-	return 0;
+	return ipt_register_target(&ipt_classify_reg);
 }
 
 static void __exit fini(void)
diff -puN net/ipv4/netfilter/ipt_DSCP.c~ipt_register_target_retval net/ipv4/netfilter/ipt_DSCP.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_DSCP.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_DSCP.c	2004-01-23 15:46:14.000000000 -0800
@@ -91,10 +91,7 @@ static struct ipt_target ipt_dscp_reg = 
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_dscp_reg))
-		return -EINVAL;
-
-	return 0;
+	return ipt_register_target(&ipt_dscp_reg);
 }
 
 static void __exit fini(void)
diff -puN net/ipv4/netfilter/ipt_ECN.c~ipt_register_target_retval net/ipv4/netfilter/ipt_ECN.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_ECN.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_ECN.c	2004-01-23 15:46:14.000000000 -0800
@@ -155,10 +155,7 @@ static struct ipt_target ipt_ecn_reg = {
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_ecn_reg))
-		return -EINVAL;
-
-	return 0;
+	return ipt_register_target(&ipt_ecn_reg);
 }
 
 static void __exit fini(void)
diff -puN net/ipv4/netfilter/ipt_LOG.c~ipt_register_target_retval net/ipv4/netfilter/ipt_LOG.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_LOG.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_LOG.c	2004-01-23 15:46:14.000000000 -0800
@@ -404,10 +404,7 @@ static struct ipt_target ipt_log_reg = {
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_log_reg))
-		return -EINVAL;
-
-	return 0;
+	return ipt_register_target(&ipt_log_reg);
 }
 
 static void __exit fini(void)
diff -puN net/ipv4/netfilter/ipt_MARK.c~ipt_register_target_retval net/ipv4/netfilter/ipt_MARK.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_MARK.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_MARK.c	2004-01-23 15:46:14.000000000 -0800
@@ -59,10 +59,7 @@ static struct ipt_target ipt_mark_reg = 
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_mark_reg))
-		return -EINVAL;
-
-	return 0;
+	return ipt_register_target(&ipt_mark_reg);
 }
 
 static void __exit fini(void)
diff -puN net/ipv4/netfilter/ipt_REJECT.c~ipt_register_target_retval net/ipv4/netfilter/ipt_REJECT.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_REJECT.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_REJECT.c	2004-01-23 15:46:14.000000000 -0800
@@ -449,9 +449,7 @@ static struct ipt_target ipt_reject_reg 
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_reject_reg))
-		return -EINVAL;
-	return 0;
+	return ipt_register_target(&ipt_reject_reg);
 }
 
 static void __exit fini(void)
diff -puN net/ipv4/netfilter/ipt_TOS.c~ipt_register_target_retval net/ipv4/netfilter/ipt_TOS.c
--- linux-262-rc1-bk1/net/ipv4/netfilter/ipt_TOS.c~ipt_register_target_retval	2004-01-23 15:46:14.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/net/ipv4/netfilter/ipt_TOS.c	2004-01-23 15:46:14.000000000 -0800
@@ -84,10 +84,7 @@ static struct ipt_target ipt_tos_reg = {
 
 static int __init init(void)
 {
-	if (ipt_register_target(&ipt_tos_reg))
-		return -EINVAL;
-
-	return 0;
+	return ipt_register_target(&ipt_tos_reg);
 }
 
 static void __exit fini(void)

_
