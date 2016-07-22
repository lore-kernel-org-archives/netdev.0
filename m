From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 1/2] devlink: write usage help messages to stderr
Date: Fri, 22 Jul 2016 18:34:29 +0200
Message-ID: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33615 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcGVQee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 12:34:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so6851952wme.0
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 09:34:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In order to not confuse reader, write help messages into stderr.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index ffefa86..f73ba95 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -909,7 +909,7 @@ static bool dl_dump_filter(struct dl *dl, struct nlattr **tb)
 
 static void cmd_dev_help(void)
 {
-	pr_out("Usage: devlink dev show [ DEV ]\n");
+	pr_err("Usage: devlink dev show [ DEV ]\n");
 }
 
 static void __pr_out_handle(const char *bus_name, const char *dev_name)
@@ -1024,10 +1024,10 @@ static int cmd_dev(struct dl *dl)
 
 static void cmd_port_help(void)
 {
-	pr_out("Usage: devlink port show [ DEV/PORT_INDEX ]\n");
-	pr_out("       devlink port set DEV/PORT_INDEX [ type { eth | ib | auto} ]\n");
-	pr_out("       devlink port split DEV/PORT_INDEX count COUNT\n");
-	pr_out("       devlink port unsplit DEV/PORT_INDEX\n");
+	pr_err("Usage: devlink port show [ DEV/PORT_INDEX ]\n");
+	pr_err("       devlink port set DEV/PORT_INDEX [ type { eth | ib | auto} ]\n");
+	pr_err("       devlink port split DEV/PORT_INDEX count COUNT\n");
+	pr_err("       devlink port unsplit DEV/PORT_INDEX\n");
 }
 
 static const char *port_type_name(uint32_t type)
@@ -1174,22 +1174,22 @@ static int cmd_port(struct dl *dl)
 
 static void cmd_sb_help(void)
 {
-	pr_out("Usage: devlink sb show [ DEV [ sb SB_INDEX ] ]\n");
-	pr_out("       devlink sb pool show [ DEV [ sb SB_INDEX ] pool POOL_INDEX ]\n");
-	pr_out("       devlink sb pool set DEV [ sb SB_INDEX ] pool POOL_INDEX\n");
-	pr_out("                           size POOL_SIZE thtype { static | dynamic }\n");
-	pr_out("       devlink sb port pool show [ DEV/PORT_INDEX [ sb SB_INDEX ]\n");
-	pr_out("                                   pool POOL_INDEX ]\n");
-	pr_out("       devlink sb port pool set DEV/PORT_INDEX [ sb SB_INDEX ]\n");
-	pr_out("                                pool POOL_INDEX th THRESHOLD\n");
-	pr_out("       devlink sb tc bind show [ DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
-	pr_out("                                 type { ingress | egress } ]\n");
-	pr_out("       devlink sb tc bind set DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
-	pr_out("                              type { ingress | egress } pool POOL_INDEX\n");
-	pr_out("                              th THRESHOLD\n");
-	pr_out("       devlink sb occupancy show { DEV | DEV/PORT_INDEX } [ sb SB_INDEX ]\n");
-	pr_out("       devlink sb occupancy snapshot DEV [ sb SB_INDEX ]\n");
-	pr_out("       devlink sb occupancy clearmax DEV [ sb SB_INDEX ]\n");
+	pr_err("Usage: devlink sb show [ DEV [ sb SB_INDEX ] ]\n");
+	pr_err("       devlink sb pool show [ DEV [ sb SB_INDEX ] pool POOL_INDEX ]\n");
+	pr_err("       devlink sb pool set DEV [ sb SB_INDEX ] pool POOL_INDEX\n");
+	pr_err("                           size POOL_SIZE thtype { static | dynamic }\n");
+	pr_err("       devlink sb port pool show [ DEV/PORT_INDEX [ sb SB_INDEX ]\n");
+	pr_err("                                   pool POOL_INDEX ]\n");
+	pr_err("       devlink sb port pool set DEV/PORT_INDEX [ sb SB_INDEX ]\n");
+	pr_err("                                pool POOL_INDEX th THRESHOLD\n");
+	pr_err("       devlink sb tc bind show [ DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
+	pr_err("                                 type { ingress | egress } ]\n");
+	pr_err("       devlink sb tc bind set DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
+	pr_err("                              type { ingress | egress } pool POOL_INDEX\n");
+	pr_err("                              th THRESHOLD\n");
+	pr_err("       devlink sb occupancy show { DEV | DEV/PORT_INDEX } [ sb SB_INDEX ]\n");
+	pr_err("       devlink sb occupancy snapshot DEV [ sb SB_INDEX ]\n");
+	pr_err("       devlink sb occupancy clearmax DEV [ sb SB_INDEX ]\n");
 }
 
 static void pr_out_sb(struct nlattr **tb)
@@ -1991,7 +1991,7 @@ static int cmd_mon_show(struct dl *dl)
 
 static void cmd_mon_help(void)
 {
-	pr_out("Usage: devlink monitor [ all | OBJECT-LIST ]\n"
+	pr_err("Usage: devlink monitor [ all | OBJECT-LIST ]\n"
 	       "where  OBJECT-LIST := { dev | port }\n");
 }
 
@@ -2010,7 +2010,7 @@ static int cmd_mon(struct dl *dl)
 
 static void help(void)
 {
-	pr_out("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
+	pr_err("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
 	       "where  OBJECT := { dev | port | sb | monitor }\n"
 	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] }\n");
 }
-- 
2.5.5
