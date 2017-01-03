From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 0/3] tipc: improve interaction
	socket-link
Date: Tue,  3 Jan 2017 10:26:45 -0500
Message-ID: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, Al Viro <viro@zeniv.linux.org.uk>
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

We fix a very real starvation problem that may occur when a link
encounters send buffer congestion. At the same time we make the 
interaction between the socket and link layer simpler and more 
consistent.

Jon Maloy (3):
  tipc: unify tipc_wait_for_sndpkt() and tipc_wait_for_sndmsg()
    functions
  tipc: modify struct tipc_plist to be more versatile
  tipc: reduce risk of user starvation during link congestion

 net/tipc/bcast.c      |   6 +-
 net/tipc/link.c       |  75 ++++-----
 net/tipc/msg.h        |   2 -
 net/tipc/name_table.c | 100 +++++++----
 net/tipc/name_table.h |  21 +--
 net/tipc/node.c       |  15 +-
 net/tipc/socket.c     | 449 ++++++++++++++++++++++----------------------------
 7 files changed, 319 insertions(+), 349 deletions(-)

-- 
2.7.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
