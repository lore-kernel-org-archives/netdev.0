From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] skbuff.h: fix kernel-doc warning for headers_end
Date: Sun, 26 Oct 2014 19:14:06 -0700
Message-ID: <544DAA6E.4090509@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42813 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbaJ0COL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 22:14:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warning in <linux/skbuff.h> by making both headers_start
and headers_end private fields.

Warning(..//include/linux/skbuff.h:654): No description found for parameter 'headers_end[0]'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/linux/skbuff.h |    4 ++++
 1 file changed, 4 insertions(+)

Or I can document those two fields if you would rather not have them
marked as private...

--- lnx-318-rc2.orig/include/linux/skbuff.h
+++ lnx-318-rc2/include/linux/skbuff.h
@@ -557,7 +557,9 @@ struct sk_buff {
 	/* fields enclosed in headers_start/headers_end are copied
 	 * using a single memcpy() in __copy_skb_header()
 	 */
+	/* private: */
 	__u32			headers_start[0];
+	/* public: */
 
 /* if you move pkt_type around you also must adapt those constants */
 #ifdef __BIG_ENDIAN_BITFIELD
@@ -642,7 +644,9 @@ struct sk_buff {
 	__u16			network_header;
 	__u16			mac_header;
 
+	/* private: */
 	__u32			headers_end[0];
+	/* public: */
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
