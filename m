From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] skbuff: fix kernel-doc
Date: Tue, 1 May 2007 18:21:56 -0700
Message-ID: <20070501182156.0b7a3205.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:60694 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946070AbXEBBSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 21:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix skbuff.h kernel-doc:
linux-2.6.21-git4//include/linux/skbuff.h:316): No description found for parameter 'transport_header'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.21-git4.orig/include/linux/skbuff.h
+++ linux-2.6.21-git4/include/linux/skbuff.h
@@ -197,7 +197,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@tstamp: Time we arrived
  *	@dev: Device we arrived on/are leaving by
  *	@iif: ifindex of device we arrived on
- *	@h: Transport layer header
+ *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
  *	@dst: destination entry
