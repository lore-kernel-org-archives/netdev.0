From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next 0/7] tipc: introduce UDP replicast
Date: Fri, 26 Aug 2016 10:52:49 +0200
Message-ID: <1472201576-26588-1-git-send-email-richard.alpe@ericsson.com>
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

This series introduces UDP replicast. A concept where we emulate multicast by
sending multiple unicast messages to configured peers. This allows TIPC to be
used in environments where IP multicast is disabled.

There is a corresponding patch series for the tipc user space tool that
allows a user to add remote addresses to the replicast list.

Richard Alpe (7):
  tipc: split UDP nl address parsing
  tipc: split UDP send function
  tipc: refactor multicast ip check
  tipc: introduce UDP replicast
  tipc: add replicast peer discovery
  tipc: add the ability to get UDP options via netlink
  tipc: add UDP remoteip dump to netlink API

 include/uapi/linux/tipc_netlink.h |   3 +
 net/tipc/bearer.c                 |  52 ++++
 net/tipc/bearer.h                 |   1 +
 net/tipc/netlink.c                |  15 +-
 net/tipc/udp_media.c              | 520 +++++++++++++++++++++++++++++++-------
 net/tipc/udp_media.h              |  46 ++++
 6 files changed, 545 insertions(+), 92 deletions(-)
 create mode 100644 net/tipc/udp_media.h

-- 
2.1.4


------------------------------------------------------------------------------
