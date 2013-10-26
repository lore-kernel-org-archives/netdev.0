From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] message reassembly
	improvements
Date: Sat, 26 Oct 2013 14:41:00 -0400
Message-ID: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
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

We introduce a new defragmentation algorithm that improves performance
and eliminates the risk of causing out-of-memory situations.

Erik Hugne (3):
  tipc: don't reroute message fragments
  tipc: message reassembly using fragment chain
  tipc: reassembly failures should cause link reset

 net/tipc/bcast.c |   16 ++++--
 net/tipc/link.c  |  161 +++++++++++++++---------------------------------------
 net/tipc/link.h  |   20 +++++--
 net/tipc/msg.h   |   12 ----
 net/tipc/node.c  |    7 ++-
 net/tipc/node.h  |    6 +-
 6 files changed, 77 insertions(+), 145 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135991&iu=/4140/ostg.clktrk
