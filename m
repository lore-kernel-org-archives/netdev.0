From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: some improvements and
	fixes
Date: Wed, 25 Mar 2015 12:07:23 -0400
Message-ID: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
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

We introduce a better algorithm for selecting when and which
users should be subject to link congestion control, plus clean
up some code for that mechanism.
Commit #3 fixes another rare race condition during packet reception.

Jon Maloy (3):
  tipc: introduce starvation free send algorithm
  tipc: clean up handling of link congestion
  tipc: eliminate race condition at dual link establishment

 net/tipc/bcast.c |   2 +-
 net/tipc/link.c  | 207 ++++++++++++++++++++++++++++++++++---------------------
 net/tipc/link.h  |   9 ++-
 net/tipc/msg.h   |  36 +++++-----
 4 files changed, 157 insertions(+), 97 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
