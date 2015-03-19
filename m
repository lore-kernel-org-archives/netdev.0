From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 0/3] tipc: small bugfix an
	support for datagram connect()
Date: Thu, 19 Mar 2015 09:02:16 +0100
Message-ID: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <netdev@vger.kernel.org>
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

Most notable in this series is patch#3 that allows programs to associate
a tipc address with a connectionless (RDM/DGRAM) socket.

v2: Fix indent issue in patch#3

Erik Hugne (3):
  tipc: remove redundant call to tipc_node_remove_conn
  tipc: do not report -EHOSTUNREACH for failed local delivery
  tipc: add support for connect() on dgram/rdm sockets

 net/tipc/link.c   |  6 ++++--
 net/tipc/socket.c | 39 ++++++++++++++++++++++++---------------
 2 files changed, 28 insertions(+), 17 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
