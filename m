From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: redesign socket-level
	flow control
Date: Mon,  2 May 2016 10:22:33 -0400
Message-ID: <1462198956-30181-1-git-send-email-jon.maloy@ericsson.com>
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

The socket-level flow control in TIPC has long been due for a major
overhaul. This series fixes this.

Jon Maloy (3):
  tipc: re-enable compensation for socket receive buffer double counting
  tipc: propagate peer node capabilities to socket layer
  tipc: redesign connection-level flow control

 net/tipc/core.c   |   8 ++-
 net/tipc/msg.h    |  14 +++++-
 net/tipc/node.c   |  21 +++++++-
 net/tipc/node.h   |   6 ++-
 net/tipc/socket.c | 144 +++++++++++++++++++++++++++++++++++-------------------
 net/tipc/socket.h |  17 +++++--
 6 files changed, 145 insertions(+), 65 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
