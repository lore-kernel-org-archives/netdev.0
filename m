From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 0/3] tipc: fix hanging socket
	connections
Date: Wed, 26 Apr 2017 10:04:59 +0200
Message-ID: <1493193902-18332-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
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

This patch series contains fixes for the socket layer to
prevent hanging / stale connections.

Parthasarathy Bhuvaragan (3):
  tipc: Fix missing connection request handling
  tipc: improve error validations for sockets in CONNECTING state
  tipc: close the connection if protocol messages contain errors

 net/tipc/socket.c | 36 +++++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
