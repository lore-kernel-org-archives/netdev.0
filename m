From: Vadim Lobanov <vadim@cs.washington.edu>
Subject: [PATCH] Trivial patch in /net/core/net-sysfs.c
Date: Sun, 23 May 2004 01:48:45 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040523014005.R31528-100000@attu2.cs.washington.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262351AbUEWIst@vger.kernel.org>
To: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Hello,

Here is a trivial patch to /net/core/net-sysfs.c, to remove 3 unnecessary 
word lengths from memory. Diffed against the base 2.6.6 tree. Please note 
that this is a first stab at attempting to submit a patch, so let me know if
something's not quite right, so that I can rework it. :)

=========================================================================

--- linux-2.6.6/net/core/net-sysfs.c    2004-05-09 19:33:19.000000000 
-0700
+++ linux-2.6.6/net/core/net-sysfs.c    2004-05-23 01:33:57.000000000 
-0700
@@ -20,9 +20,9 @@
 #define to_class_dev(obj) container_of(obj,struct class_device,kobj)
 #define to_net_dev(class) container_of(class, struct net_device, 
class_dev)
 
-static const char *fmt_hex = "%#x\n";
-static const char *fmt_dec = "%d\n";
-static const char *fmt_ulong = "%lu\n";
+static const char fmt_hex[] = "%#x\n";
+static const char fmt_dec[] = "%d\n";
+static const char fmt_ulong[] = "%lu\n";
 
 static inline int dev_isalive(const struct net_device *dev) 
 {

========================================================================

-Vadim Lobanov
