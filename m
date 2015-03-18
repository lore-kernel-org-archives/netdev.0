From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/3] tipc: fix netns refcnt leak
Date: Wed, 18 Mar 2015 09:32:56 +0800
Message-ID: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, cwang@twopensource.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
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

The series aims to eliminate the issue of netns refcount leak. But
during fixing it, another two additional problems are found. So all
of known issues associated with the netns refcnt leak are resolved
at the same time in the patchset.

Ying Xue (3):
  tipc: fix netns refcnt leak
  tipc: fix a potential deadlock when nametable is purged
  tipc: withdraw tipc topology server name when namespace is deleted

 net/tipc/name_table.c |    4 +--
 net/tipc/server.c     |   47 ++++++++++++++++++++++++----
 net/tipc/socket.c     |   83 +------------------------------------------------
 net/tipc/socket.h     |    4 ---
 4 files changed, 44 insertions(+), 94 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
