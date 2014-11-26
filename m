From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 06/11] tipc: remove unused
	between routine
Date: Wed, 26 Nov 2014 11:41:50 +0800
Message-ID: <1416973315-6047-7-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.h |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/tipc/link.h b/net/tipc/link.h
index 1681076..7711234 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -253,15 +253,6 @@ static inline u32 mod(u32 x)
 	return x & 0xffffu;
 }
 
-static inline int between(u32 lower, u32 upper, u32 n)
-{
-	if ((lower < n) && (n < upper))
-		return 1;
-	if ((upper < lower) && ((n > lower) || (n < upper)))
-		return 1;
-	return 0;
-}
-
 static inline int less_eq(u32 left, u32 right)
 {
 	return mod(right - left) < 32768u;
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
