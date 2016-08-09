From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH iproute2 1/2] tipc: fix UDP bearer synopsis
Date: Tue, 9 Aug 2016 10:34:29 +0200
Message-ID: <1470731670-12723-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Local ip is not required to identify a UDP bearer and shouldn't be
passed to bearer disable, set or get. In this patch we remove the
localip entry from the synopsis of these functions.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 man/man8/tipc-bearer.8 | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/man/man8/tipc-bearer.8 b/man/man8/tipc-bearer.8
index 50a1ed2..846f1db 100644
--- a/man/man8/tipc-bearer.8
+++ b/man/man8/tipc-bearer.8
@@ -39,14 +39,12 @@ tipc-bearer \- show or modify TIPC bearers
 .B tipc bearer disable media
 .br
 .RB "{ { " eth " | " ib " } " device
-.IR DEVICE
+.IR "DEVICE " }
 .RB "|"
 .br
 .RB "{ " udp
 .B name
-.IR NAME
-.B localip
-.IR LOCALIP " } }"
+.IR NAME " }"
 .br
 
 .ti -8
@@ -65,9 +63,7 @@ tipc-bearer \- show or modify TIPC bearers
 .br
 .RB "{ " udp
 .B name
-.IR NAME
-.B localip
-.IR LOCALIP " } }"
+.IR NAME " }"
 .br
 
 .ti -8
@@ -80,9 +76,7 @@ tipc-bearer \- show or modify TIPC bearers
 .br
 .RB "{ " udp
 .B name
-.IR NAME
-.B localip
-.IR LOCALIP " } }"
+.IR NAME " }"
 .br
 
 .ti -8
-- 
2.1.4


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. http://sdm.link/zohodev2dev
