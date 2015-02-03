From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/4] tipc: some small fixes
Date: Tue,  3 Feb 2015 08:59:16 -0500
Message-ID: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
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

During extensive testing and analysis of running dual links between
nodes, we have encountered some issues that potentially may cause
problems. We choose to fix those proactively in this series. 

Jon Maloy (4):
  tipc: add reference count to struct tipc_link
  tipc: avoid stale link after aborted failover
  tipc: eliminate race during node creation
  tipc: separate link starting event from link timeout event

 net/tipc/discover.c |  9 ++----
 net/tipc/link.c     | 83 ++++++++++++++++++++++++++++++++---------------------
 net/tipc/link.h     |  3 ++
 net/tipc/node.c     | 15 ++++++----
 4 files changed, 65 insertions(+), 45 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
