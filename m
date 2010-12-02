From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7] inetpeer: Fix incorrect comment about inetpeer struct
 size.
Date: Thu, 02 Dec 2010 12:42:07 -0800 (PST)
Message-ID: <20101202.124207.189705683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757677Ab0LBUlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:41:40 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4F04624C08A
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:42:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now with ipv6 support it is no longer less than 64 bytes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 5161bfd..599d96e 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -35,7 +35,6 @@ struct inet_peer {
 	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
 	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp
 	 * We can share memory with rcu_head to keep inet_peer small
-	 * (less then 64 bytes)
 	 */
 	union {
 		struct {
-- 
1.7.3.2

