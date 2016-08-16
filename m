From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/2] tipc: bearer and link
	improvements
Date: Tue, 16 Aug 2016 11:53:49 -0400
Message-ID: <1471362831-30006-1-git-send-email-jon.maloy@ericsson.com>
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

The first commit makes it possible to set and check the 'blocked' state
of a bearer from the generic bearer layer. The second commit is a small
improvement to the link congestion mechanism.

Jon Maloy (2):
  tipc: make bearer packet filtering generic
  tipc: ensure that link congestion and wakeup use same criteria

 net/tipc/bearer.c    | 78 +++++++++++++++++++++++++++-------------------------
 net/tipc/bearer.h    |  1 +
 net/tipc/link.c      | 18 ++++++------
 net/tipc/udp_media.c |  2 +-
 4 files changed, 52 insertions(+), 47 deletions(-)

-- 
2.7.4


------------------------------------------------------------------------------
