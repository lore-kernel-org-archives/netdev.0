From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 1/9] net: Allocate a new 16 bits for flags in
 skbuff
Date: Wed, 27 Aug 2014 21:44:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272142480.550@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:49225 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbaH1L1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 07:27:37 -0400
Received: by mail-oi0-f74.google.com with SMTP id v63so188186oia.3
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 04:27:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b69b7b5..3c9574c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -598,6 +598,10 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
+	kmemcheck_bitfield_begin(flags3);
+	/* 16 bit hole */
+	kmemcheck_bitfield_end(flags3);
+
 	__be16			inner_protocol;
 	__u16			inner_transport_header;
 	__u16			inner_network_header;
-- 
2.1.0.rc2.206.gedb03e5
