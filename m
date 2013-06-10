From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] [v2] ipv4: remove is_data also from ip_options documentation.
Date: Mon, 10 Jun 2013 18:58:16 +0300
Message-ID: <1370879896-5846-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:51457 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab3FJM60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 08:58:26 -0400
Received: by mail-ee0-f50.google.com with SMTP id d49so2955811eek.37
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 05:58:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ef722495c8867aacc1db0675a6737e5cf1e72e07
( [IPV4]: Remove unused ip_options->is_data) removed the unused is_data
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
