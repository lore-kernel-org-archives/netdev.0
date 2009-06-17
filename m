From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] skbuff.h: fix skb_dst  kernel-doc
Date: Tue, 16 Jun 2009 19:56:38 -0700
Message-ID: <4A385B66.8070902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:32631 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754935AbZFQC4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 22:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc warnings (missing + extra entries) in skbuff.h.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.30-git10.orig/include/linux/skbuff.h
+++ linux-2.6.30-git10/include/linux/skbuff.h
@@ -264,7 +264,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
- *	@dst: destination entry
+ *	@_skb_dst: destination entry
  *	@sp: the security path, used for xfrm
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@len: Length of actual data
