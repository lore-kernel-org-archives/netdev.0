From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] [RESEND] [TRIVIAL] isdn: hisax: Fix typo 'HISAX_DE_AOC'
Date: Sun, 30 Oct 2011 13:00:44 +0100
Message-ID: <1319976044.14409.14.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That should probably be 'CONFIG_DE_AOC'.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
This is just the most obvious way to reconcile an unused Kconfig symbol
(DE_AOC) and an unknown macro (HISAX_DE_AOC). But it's basically just
educated guesswork. Entirely untested too. Added maintainer and netdev,
since this might be stretching the definition of a trivial patch.

 drivers/isdn/hisax/l3dss1.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hisax/l3dss1.c b/drivers/isdn/hisax/l3dss1.c
index b0d9ab1..6a8acf6 100644
--- a/drivers/isdn/hisax/l3dss1.c
+++ b/drivers/isdn/hisax/l3dss1.c
@@ -353,7 +353,7 @@ l3dss1_parse_facility(struct PStack *st, struct l3_process *pc,
 			         { l3dss1_dummy_invoke(st, cr, id, ident, p, nlen);
                                    return;
                                  } 
-#ifdef HISAX_DE_AOC
+#ifdef CONFIG_DE_AOC
 			{
 
 #define FOO1(s,a,b) \
@@ -422,9 +422,9 @@ l3dss1_parse_facility(struct PStack *st, struct l3_process *pc,
 #undef FOO1
 
 			}
-#else  /* not HISAX_DE_AOC */
+#else  /* not CONFIG_DE_AOC */
                         l3_debug(st, "invoke break");
-#endif /* not HISAX_DE_AOC */
+#endif /* not CONFIG_DE_AOC */
 			break;
 		case 2:	/* return result */
 			 /* if no process available handle separately */ 
-- 
1.7.4.4
