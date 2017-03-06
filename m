From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 net-next] devlink: Add json and pretty options to help and man
Date: Mon,  6 Mar 2017 11:06:18 +0200
Message-ID: <1488791178-17220-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54660 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753183AbdCFJNF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 04:13:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While at it also fixed missing double dash for long opts.

Signed-off-by: Roi Dayan <roid@mellanox.com>
---
 devlink/devlink.c  |  2 +-
 man/man8/devlink.8 | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index c357580..e90226e 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -2470,7 +2470,7 @@ static void help(void)
 {
 	pr_err("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
 	       "where  OBJECT := { dev | port | sb | monitor }\n"
-	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] }\n");
+	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] | -j[json] | -p[pretty] }\n");
 }
 
 static int dl_cmd(struct dl *dl)
diff --git a/man/man8/devlink.8 b/man/man8/devlink.8
index cf0563b..a480766 100644
--- a/man/man8/devlink.8
+++ b/man/man8/devlink.8
@@ -20,19 +20,29 @@ devlink \- Devlink tool
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
 \fB\-n\fR[\fIno-nice-names\fR] }
+\fB\-j\fR[\fIjson\fR] }
+\fB\-p\fR[\fIpretty\fR] }
 
 .SH OPTIONS
 
 .TP
-.BR "\-V" , " -Version"
+.BR "\-V" , " --Version"
 Print the version of the
 .B devlink
 utility and exit.
 
 .TP
-.BR "\-n" , " -no-nice-names"
+.BR "\-n" , " --no-nice-names"
 Turn off printing out nice names, for example netdevice ifnames instead of devlink port identification.
 
+.TP
+.BR "\-j" , " --json"
+Generate JSON output.
+
+.TP
+.BR "\-p" , " --pretty"
+When combined with -j generate a pretty JSON output.
+
 .SS
 .I OBJECT
 
-- 
2.7.4
