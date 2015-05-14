From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/8] tipc: some link layer
	improvements
Date: Thu, 14 May 2015 10:46:10 -0400
Message-ID: <1431614778-17582-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
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

We continue eliminating redundant complexity at the link layer, and
add a couple of improvements to the packet sending functionality.


Jon Maloy (8):
  tipc: simplify resetting and disabling of bearers
  tipc: simplify link timer handling
  tipc: simplify include dependencies
  tipc: simplify packet sequence number handling
  tipc: rename fields in struct tipc_link
  tipc: simplify link supervision checkpointing
  tipc: improve link congestion algorithm
  tipc: add packet sequence number at instant of transmission

 net/tipc/addr.c   |   7 --
 net/tipc/addr.h   |   8 ++
 net/tipc/bcast.c  |  20 ++---
 net/tipc/bearer.c |  18 ++--
 net/tipc/bearer.h |   2 +-
 net/tipc/core.h   |  37 +++++++--
 net/tipc/link.c   | 243 +++++++++++++++++++++++-------------------------------
 net/tipc/link.h   |  59 +++----------
 net/tipc/msg.c    |  51 ++++++------
 net/tipc/msg.h    |  37 +++++----
 net/tipc/net.c    |   1 +
 net/tipc/node.c   |   3 +-
 net/tipc/node.h   |   2 -
 net/tipc/socket.c |   1 +
 14 files changed, 225 insertions(+), 264 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
