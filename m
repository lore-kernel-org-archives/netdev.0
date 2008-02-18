From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix kernel-doc warnings in header files
Date: Mon, 18 Feb 2008 13:26:47 -0800
Message-ID: <20080218132647.88472082.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17989 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbYBRV2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 16:28:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add missing structure kernel-doc descriptions to sock.h & skbuff.h
to fix kernel-doc warnings.

(I think that Stephen H. sent a similar patch, but I can't find it.
I just want to kill the warnings, with either patch.)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    2 ++
 include/net/sock.h     |    1 +
 2 files changed, 3 insertions(+)

--- linux-2625-rc1g4-kdoc.orig/include/linux/skbuff.h
+++ linux-2625-rc1g4-kdoc/include/linux/skbuff.h
@@ -232,6 +232,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@mark: Generic packet mark
  *	@nfct: Associated connection, if any
  *	@ipvs_property: skbuff is owned by ipvs
+ *	@peeked: this packet has been seen already, so stats have been
+ *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
  *	@nfctinfo: Relationship of this skb to the connection
  *	@nfct_reasm: netfilter conntrack re-assembly pointer
--- linux-2625-rc1g4-kdoc.orig/include/net/sock.h
+++ linux-2625-rc1g4-kdoc/include/net/sock.h
@@ -180,6 +180,7 @@ struct sock_common {
   *	@sk_sndmsg_off: cached offset for sendmsg
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
+  *	@sk_mark: generic packet mark
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
   *	@sk_data_ready: callback to indicate there is data to be processed
