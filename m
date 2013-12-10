From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 0/2] tipc: corrections related to
	tasklet job mechanism
Date: Mon,  9 Dec 2013 22:54:45 -0800
Message-ID: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
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

These commits correct two bugs related to tipc' service for launching
functions for asynchronous execution in a separate tasklet.

Jon Maloy (1):
  tipc: correct the order of stopping services at rmmod

Ying Xue (1):
  tipc: protect handler_enabled variable with qitem_lock spin lock

 net/tipc/core.c    |    7 ++++---
 net/tipc/handler.c |   11 ++++++++---
 2 files changed, 12 insertions(+), 6 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Sponsored by Intel(R) XDK 
Develop, test and display web and hybrid apps with a single code base.
Download it for free now!
http://pubads.g.doubleclick.net/gampad/clk?id=111408631&iu=/4140/ostg.clktrk
