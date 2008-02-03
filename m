From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH 7/8] kernel-doc: fix network header warnings
Date: Sun, 3 Feb 2008 15:06:54 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0802031447270.3021@shark.he.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:43846 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755374AbYBCXG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2008 18:06:56 -0500
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 3 Feb 2008 15:06:54 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add missing structure kernel-doc descriptions to sock.h & skbuff.h
to fix kernel-doc warnings.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
  include/linux/skbuff.h |    2 ++
  include/net/sock.h     |    1 +
  2 files changed, 3 insertions(+)

--- linux-2.6.24-git12.orig/include/linux/skbuff.h
+++ linux-2.6.24-git12/include/linux/skbuff.h
@@ -232,6 +232,8 @@ typedef unsigned char *sk_buff_data_t;
   *	@mark: Generic packet mark
   *	@nfct: Associated connection, if any
   *	@ipvs_property: skbuff is owned by ipvs
+ *	@peeked: this packet has been seen already, so stats have been
+ *		done for it, don't do them again
   *	@nf_trace: netfilter packet trace flag
   *	@nfctinfo: Relationship of this skb to the connection
   *	@nfct_reasm: netfilter conntrack re-assembly pointer
--- linux-2.6.24-git12.orig/include/net/sock.h
+++ linux-2.6.24-git12/include/net/sock.h
@@ -180,6 +180,7 @@ struct sock_common {
    *	@sk_sndmsg_off: cached offset for sendmsg
    *	@sk_send_head: front of stuff to transmit
    *	@sk_security: used by security modules
+  *	@sk_mark: generic packet mark
    *	@sk_write_pending: a write to stream socket waits to start
    *	@sk_state_change: callback to indicate change in the state of the sock
    *	@sk_data_ready: callback to indicate there is data to be processed
