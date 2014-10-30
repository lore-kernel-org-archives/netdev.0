From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] tipc: spelling errors
Date: Wed, 29 Oct 2014 22:58:51 -0700
Message-ID: <20141029225851.03651f3f@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33980 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbaJ3F7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 01:59:01 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so4755262pad.17
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 22:59:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/tipc/msg.c    |    4 ++--
 net/tipc/socket.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- a/net/tipc/socket.c	2014-10-27 21:06:04.243288996 -0700
+++ b/net/tipc/socket.c	2014-10-27 21:06:04.239288981 -0700
@@ -1556,7 +1556,7 @@ static void tipc_data_ready(struct sock
  * @tsk: TIPC socket
  * @msg: message
  *
- * Returns 0 (TIPC_OK) if everyting ok, -TIPC_ERR_NO_PORT otherwise
+ * Returns 0 (TIPC_OK) if everything ok, -TIPC_ERR_NO_PORT otherwise
  */
 static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 {
--- a/net/tipc/msg.c	2014-10-27 21:06:04.243288996 -0700
+++ b/net/tipc/msg.c	2014-10-27 21:06:04.239288981 -0700
@@ -91,7 +91,7 @@ struct sk_buff *tipc_msg_create(uint use
  * @*headbuf: in:  NULL for first frag, otherwise value returned from prev call
  *            out: set when successful non-complete reassembly, otherwise NULL
  * @*buf:     in:  the buffer to append. Always defined
- *            out: head buf after sucessful complete reassembly, otherwise NULL
+ *            out: head buf after successful complete reassembly, otherwise NULL
  * Returns 1 when reassembly complete, otherwise 0
  */
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
@@ -311,7 +311,7 @@ bool tipc_msg_bundle(struct sk_buff *bbu
  * @mtu:  max allowable size for the bundle buffer, inclusive header
  * @dnode: destination node for message. (Not always present in header)
  * Replaces buffer if successful
- * Returns true if sucess, otherwise false
+ * Returns true if success, otherwise false
  */
 bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode)
 {
