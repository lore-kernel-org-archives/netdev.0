From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: some small fixes
Date: Tue,  5 Apr 2016 12:20:52 -0400
Message-ID: <1459873255-32354-1-git-send-email-jon.maloy@ericsson.com>
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

When running TIPC in large clusters we experience behavior that
may potentially become problematic in the future. This series
picks some low-hanging fruit in this regard, and also fixes a
couple of other minor issues.

Jon Maloy (3):
  tipc: eliminate buffer leak in bearer layer
  tipc: stricter filtering of packets in bearer layer
  tipc: reduce transmission rate of reset messages when link is down

 net/tipc/bearer.c   | 101 ++++++++++++++++++++++++++++++----------------------
 net/tipc/discover.c |   7 ++--
 net/tipc/discover.h |   2 +-
 net/tipc/link.c     |  10 +++---
 net/tipc/msg.h      |   5 +++
 5 files changed, 73 insertions(+), 52 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
