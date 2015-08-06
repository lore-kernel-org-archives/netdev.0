From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] net:wimax: Fix doucble word "the the" in networking.xml
Date: Thu,  6 Aug 2015 12:52:47 +0900
Message-ID: <1438833167-18798-1-git-send-email-standby24x7@gmail.com>
Cc: corbet@lwn.net, Masanari Iida <standby24x7@gmail.com>
To: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	davem@davemloft.net, netdev@vger.kernel.org, trivial@kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix a double word "the the"
in Documentation/DocBook/networking.xml and
Documentation/DocBook/networking/API-Wimax-report-rfkill-sw.html.

These files are generated from comment in source, so I had to
fix the typo in net/wimax/io-rfkill.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/wimax/op-rfkill.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 7d73054..477364a 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -135,8 +135,7 @@ EXPORT_SYMBOL_GPL(wimax_report_rfkill_hw);
  * @state: New state of the RF kill switch. %WIMAX_RF_ON radio on,
  *     %WIMAX_RF_OFF radio off.
  *
- * Reports changes in the software RF switch state to the the WiMAX
- * stack.
+ * Reports changes in the software RF switch state to the WiMAX stack.
  *
  * The main use is during initialization, so the driver can query the
  * device for its current software radio kill switch state and feed it
-- 
2.5.0
