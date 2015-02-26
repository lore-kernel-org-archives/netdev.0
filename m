From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 0/5] tipc: bug fix and some
	improvements
Date: Thu, 26 Feb 2015 07:43:25 +0100
Message-ID: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
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

From: Erik Hugne <erik.hugne@ericsson.com>

Most important is a fix for a nullptr exception that would occur when
name table subscriptions fail. The remaining patches are performance
improvements and cosmetic changes.


Erik Hugne (5):
  tipc: only create header copy for name distr messages
  tipc: fix nullpointer bug when subscribing to events
  tipc: purge links when bearer is disabled
  tipc: rename media/msg related definitions
  tipc: make media address offset a common define

 net/tipc/bearer.c     |  2 +-
 net/tipc/bearer.h     |  5 +++--
 net/tipc/eth_media.c  |  8 +++-----
 net/tipc/ib_media.c   |  2 +-
 net/tipc/msg.h        |  4 ++--
 net/tipc/name_distr.c |  2 +-
 net/tipc/subscr.c     | 24 +++++-------------------
 7 files changed, 16 insertions(+), 31 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
