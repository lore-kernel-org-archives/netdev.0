From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/23) sk98: use module_param
Date: Thu, 11 Nov 2004 15:54:25 -0800
Message-ID: <20041111155425.71002924@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use new format module_param rather than now deprecated MODULE_PARM

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 14:08:18 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 14:08:18 -08:00
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
@@ -462,6 +443,26 @@
 static char *ModerationMask[SK_MAX_CARD_PARAM];
 static char *AutoSizing[SK_MAX_CARD_PARAM];
 static char *Stats[SK_MAX_CARD_PARAM];
+
+module_param_array(Speed_A, charp, NULL, 0);
+module_param_array(Speed_B, charp, NULL, 0);
+module_param_array(AutoNeg_A, charp, NULL, 0);
+module_param_array(AutoNeg_B, charp, NULL, 0);
+module_param_array(DupCap_A, charp, NULL, 0);
+module_param_array(DupCap_B, charp, NULL, 0);
+module_param_array(FlowCtrl_A, charp, NULL, 0);
+module_param_array(FlowCtrl_B, charp, NULL, 0);
+module_param_array(Role_A, charp, NULL, 0);
+module_param_array(Role_B, charp, NULL, 0);
+module_param_array(ConType, charp, NULL, 0);
+module_param_array(PrefPort, charp, NULL, 0);
+module_param_array(RlmtMode, charp, NULL, 0);
+/* used for interrupt moderation */
+module_param_array(IntsPerSec, int, NULL, 0);
+module_param_array(Moderation, charp, NULL, 0);
+module_param_array(Stats, charp, NULL, 0);
+module_param_array(ModerationMask, charp, NULL, 0);
+module_param_array(AutoSizing, charp, NULL, 0);
 
 /*****************************************************************************
  *
