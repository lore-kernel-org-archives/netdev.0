From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 5/5] skge: use module_param_array
Date: Mon, 18 Oct 2004 15:24:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018152454.66f9a5f0@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use module_param_array

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-10-18 15:17:11 -07:00
+++ b/drivers/net/sk98lin/skge.c	2004-10-18 15:17:11 -07:00
@@ -109,6 +109,7 @@
 #include	"h/skversion.h"
 
 #include	<linux/module.h>
+#include	<linux/moduleparam.h>
 #include	<linux/init.h>
 #include 	<linux/proc_fs.h>
 
@@ -358,26 +359,6 @@
 MODULE_AUTHOR("Mirko Lindner <mlindner@syskonnect.de>");
 MODULE_DESCRIPTION("SysKonnect SK-NET Gigabit Ethernet SK-98xx driver");
 MODULE_LICENSE("GPL");
-MODULE_PARM(Speed_A,    "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(Speed_B,    "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(AutoNeg_A,  "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(AutoNeg_B,  "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(DupCap_A,   "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(DupCap_B,   "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(FlowCtrl_A, "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(FlowCtrl_B, "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(Role_A,	"1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(Role_B,	"1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(ConType,	"1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(PrefPort,   "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(RlmtMode,   "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-/* used for interrupt moderation */
-MODULE_PARM(IntsPerSec,     "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "i");
-MODULE_PARM(Moderation,     "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(Stats,          "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(ModerationMask, "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-MODULE_PARM(AutoSizing,     "1-" __MODULE_STRING(SK_MAX_CARD_PARAM) "s");
-
 
 #ifdef LINK_SPEED_A
 static char *Speed_A[SK_MAX_CARD_PARAM] = LINK_SPEED;
@@ -462,6 +443,27 @@
 static char *ModerationMask[SK_MAX_CARD_PARAM];
 static char *AutoSizing[SK_MAX_CARD_PARAM];
 static char *Stats[SK_MAX_CARD_PARAM];
+
+static int nparams;
+module_param_array(Speed_A, charp, nparams, 0);
+module_param_array(Speed_B, charp, nparams, 0);
+module_param_array(AutoNeg_A, charp, nparams, 0);
+module_param_array(AutoNeg_B, charp, nparams, 0);
+module_param_array(DupCap_A, charp, nparams, 0);
+module_param_array(DupCap_B, charp, nparams, 0);
+module_param_array(FlowCtrl_A, charp, nparams, 0);
+module_param_array(FlowCtrl_B, charp, nparams, 0);
+module_param_array(Role_A, charp, nparams, 0);
+module_param_array(Role_B, charp, nparams, 0);
+module_param_array(ConType, charp, nparams, 0);
+module_param_array(PrefPort, charp, nparams, 0);
+module_param_array(RlmtMode, charp, nparams, 0);
+/* used for interrupt moderation */
+module_param_array(IntsPerSec, int, nparams, 0);
+module_param_array(Moderation, charp, nparams, 0);
+module_param_array(Stats, charp, nparams, 0);
+module_param_array(ModerationMask, charp, nparams, 0);
+module_param_array(AutoSizing, charp, nparams, 0);
 
 /*****************************************************************************
  *
