From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 0/5] tipc: netlink updates for
	neighbour monitor
Date: Tue, 26 Jul 2016 08:47:17 +0200
Message-ID: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
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

This series contains the updates to configure and read the attributes for
neighbour monitor.

v2: rebase on top of net-next

Parthasarathy Bhuvaragan (5):
  tipc: introduce constants for tipc address validation
  tipc: make cluster size threshold for monitoring configurable
  tipc: get monitor threshold for the cluster
  tipc: add a function to get the bearer name
  tipc: dump monitor attributes

 include/uapi/linux/tipc.h         |  30 ++++++-
 include/uapi/linux/tipc_netlink.h |  37 +++++++++
 net/tipc/addr.h                   |   5 +-
 net/tipc/bearer.c                 |  25 +++++-
 net/tipc/bearer.h                 |   1 +
 net/tipc/monitor.c                | 152 +++++++++++++++++++++++++++++++++++
 net/tipc/monitor.h                |   9 +++
 net/tipc/netlink.c                |  27 ++++++-
 net/tipc/netlink.h                |   1 +
 net/tipc/node.c                   | 165 ++++++++++++++++++++++++++++++++++++++
 net/tipc/node.h                   |   5 ++
 11 files changed, 445 insertions(+), 12 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports.http://sdm.link/zohodev2dev
