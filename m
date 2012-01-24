From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net] drivers/net: dsa/mv88e6xxx.c files need linux/module.h
Date: Tue, 24 Jan 2012 15:41:40 -0500
Message-ID: <1327437700-8204-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: buytenh@wantstofly.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39625 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756446Ab2AXUlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 15:41:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An implicit instance of module.h leaked back into existence
and was masking the fact that these drivers weren't calling
out the include for itself.  Fix the drivers before we remove
the implicit include path via net/netprio_cgroup.h file.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 7fc4e81..325391d 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/list.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index c0a458f..05b5f92 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/list.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e0eb6824..55888b0 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/list.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5467c04..a2c62c2 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/list.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
-- 
1.7.7.2
