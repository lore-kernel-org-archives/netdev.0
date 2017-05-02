From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 0/2] tipc: refactor socket receive
	functions
Date: Tue, 2 May 2017 18:16:52 +0200
Message-ID: <1493741814-25899-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
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

We try to make the functions tipc_sk_recvmsg() and tipc_sk_recvstream() more readable.

Jon Maloy (2):
  tipc: refactor function tipc_sk_recvmsg()
  tipc: refactor function tipc_sk_recv_stream()

 net/tipc/socket.c | 266 +++++++++++++++++++++++++-----------------------------
 1 file changed, 122 insertions(+), 144 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
