From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 6/6]: act_api.c: kill some exports
Date: Tue, 11 Jan 2005 22:46:34 +0100
Message-ID: <41E4493A.8000704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010104040709050701000308"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010104040709050701000308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------010104040709050701000308
Content-Type: text/x-patch;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="06.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 22:22:57+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: kill some exports
#   
#   init, destroy, dump etc. should be performed through Thomas's tcf_exts,
#   don't export the act_api.c functions to modules. tcf_action_dump_1
#   will follow once tcf_dump_walker is converted to callbacks.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/11 22:22:49+01:00 kaber@coreworks.de +0 -6
#   [PKT_SCHED]: act_api.c: kill some exports
#   
#   init, destroy, dump etc. should be performed through Thomas's tcf_exts,
#   don't export the act_api.c functions to modules. tcf_action_dump_1
#   will follow once tcf_dump_walker is converted to callbacks.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-11 22:32:30 +01:00
+++ b/net/sched/act_api.c	2005-01-11 22:32:30 +01:00
@@ -883,11 +883,5 @@
 
 EXPORT_SYMBOL(tcf_register_action);
 EXPORT_SYMBOL(tcf_unregister_action);
-EXPORT_SYMBOL(tcf_action_init_1);
-EXPORT_SYMBOL(tcf_action_init);
-EXPORT_SYMBOL(tcf_action_destroy);
 EXPORT_SYMBOL(tcf_action_exec);
-EXPORT_SYMBOL(tcf_action_copy_stats);
-EXPORT_SYMBOL(tcf_action_dump);
 EXPORT_SYMBOL(tcf_action_dump_1);
-EXPORT_SYMBOL(tcf_action_dump_old);

--------------010104040709050701000308--
