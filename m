From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ipv4: remove is_data also from ip_options documentation.
Date: Mon, 10 Jun 2013 17:27:09 +0300
Message-ID: <1370874429-4458-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:54606 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3FJL1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 07:27:23 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so1468597eaj.27
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 04:27:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ef722495c8867aacc1db0675a6737e5cf1e72e07 removed the unused is_data
member from ip_options struct.

This patch removes is_data also from the documentation of the ip_options struct.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 include/net/inet_sock.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 7235ae7..b21a7f0 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -32,7 +32,6 @@
  *
  * @faddr - Saved first hop address
  * @nexthop - Saved nexthop address in LSRR and SSRR
- * @is_data - Options in __data, rather than skb
  * @is_strictroute - Strict source route
  * @srr_is_hit - Packet destination addr was our one
  * @is_changed - IP checksum more not valid
-- 
1.8.1.4
