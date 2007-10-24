From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport sock_enable_timestamp
Date: Wed, 24 Oct 2007 18:24:05 +0200
Message-ID: <20071024162405.GC30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:33369 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759178AbXJXQXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:23:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sock_enable_timestamp() no longer has any modular users.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
c207a1b7709635c74b953324e60ab5a732ea279c 
diff --git a/net/core/sock.c b/net/core/sock.c
index febbcbc..bba9949 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1649,7 +1649,6 @@ void sock_enable_timestamp(struct sock *sk)
 		net_enable_timestamp();
 	}
 }
-EXPORT_SYMBOL(sock_enable_timestamp);
 
 /*
  *	Get a socket option on an socket.

