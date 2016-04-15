From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/5] tipc: improvements to the
	link setup algorithm
Date: Fri, 15 Apr 2016 13:33:02 -0400
Message-ID: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
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

This series addresses some smaller issues regarding the link setup 
algorithm. The first commit fixes a rare bug we have discovered during
testing; the second one may have some future impact on cluster 
scalabilty, while remaining ones can be regarded as cosmetic in
a wider sense of the word.

Jon Maloy (5):
  tipc: guarantee peer bearer id exchange after reboot
  tipc: reduce transmission rate of reset messages when link is down
  tipc: refactor function tipc_link_timeout()
  tipc: ensure that first packets on link are sent in order
  tipc: let first message on link be a state message

 net/tipc/link.c | 55 ++++++++++++++++++++++++++++++-------------------------
 net/tipc/link.h |  2 +-
 net/tipc/msg.h  | 10 ++++++++++
 net/tipc/node.c |  9 ++++++++-
 4 files changed, 49 insertions(+), 27 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
