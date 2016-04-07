From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v3 0/2]  tipc: some small fixes
Date: Thu,  7 Apr 2016 10:09:12 -0400
Message-ID: <1460038154-26856-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net, ying.xue@windriver.com
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

When fix a minor buffer leak, and ensure that bearers filter packets
correctly while they are being shut down.

v2: Corrected typos in commit #3, as per feedback from S. Shtylyov
v3: Removed commit #3 from the series. Improved version will be 
    re-submitted later.

Jon Maloy (2):
  tipc: eliminate buffer leak in bearer layer
  tipc: stricter filtering of packets in bearer layer

 net/tipc/bearer.c   | 101 ++++++++++++++++++++++++++++++----------------------
 net/tipc/discover.c |   7 ++--
 net/tipc/discover.h |   2 +-
 net/tipc/msg.h      |   5 +++
 4 files changed, 67 insertions(+), 48 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
