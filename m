From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/4] tipc: link setup and
	failover improvements
Date: Tue,  7 Jan 2014 17:02:40 -0500
Message-ID: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
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

This series consists of four unrelated commits with different purposes.

- Commit #1 is purely cosmetic and pedagogic, hopefully making the
  failover/tunneling logics slightly easier to understand. 
- Commit #2 fixes a bug that has always been in the code, but was not
  discovered until very recently.
- Commit #3 fixes a non-fatal race issue in the neighbour discovery
  code.
- Commit #4 removes an unnecessary indirection step during link 
  startup.

Jon Maloy (3):
  tipc: rename functions related to link failover and improve comments
  tipc: remove 'has_redundant_link' flag from STATE link protocol
    messages
  tipc: make link start event synchronous

Ying Xue (1):
  tipc: introduce new spinlock to protect struct link_req

 net/tipc/bcast.c    |    2 +-
 net/tipc/bearer.c   |    2 +-
 net/tipc/bearer.h   |    3 +-
 net/tipc/discover.c |   11 ++++--
 net/tipc/link.c     |   96 +++++++++++++++++++++++++--------------------------
 net/tipc/link.h     |   17 +++++----
 net/tipc/node.c     |    4 +--
 net/tipc/node.h     |    2 --
 8 files changed, 73 insertions(+), 64 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
