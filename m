From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 2/3] net/sock.h: add missing kernel-doc notation
Date: Mon, 9 Aug 2010 16:41:07 -0700
Message-ID: <20100809164107.a992561a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21778 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757233Ab0HIXoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 19:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add missing kernel-doc notation to struct sock:

Warning(include/net/sock.h:324): No description found for parameter 'sk_peer_pid'
Warning(include/net/sock.h:324): No description found for parameter 'sk_peer_cred'
Warning(include/net/sock.h:324): No description found for parameter 'sk_classid'
Warning(include/net/sock.h:324): Excess struct/union/enum/typedef member 'sk_peercred' description in 'sock'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/sock.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- linux-2.6.35-git8.orig/include/net/sock.h
+++ linux-2.6.35-git8/include/net/sock.h
@@ -195,7 +195,8 @@ struct sock_common {
   *	@sk_priority: %SO_PRIORITY setting
   *	@sk_type: socket type (%SOCK_STREAM, etc)
   *	@sk_protocol: which protocol this socket belongs in this network family
-  *	@sk_peercred: %SO_PEERCRED setting
+  *	@sk_peer_pid: &struct pid for this socket's peer
+  *	@sk_peer_cred: %SO_PEERCRED setting
   *	@sk_rcvlowat: %SO_RCVLOWAT setting
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
@@ -211,6 +212,7 @@ struct sock_common {
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
+  *	@sk_classid: this socket's cgroup classid
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
   *	@sk_data_ready: callback to indicate there is data to be processed
