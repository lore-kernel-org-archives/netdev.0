From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport __inet_hash_connect
Date: Wed, 13 Feb 2008 23:29:46 +0200
Message-ID: <20080213212946.GK3383@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:47466 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762987AbYBMVaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 16:30:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the unused EXPORT_SYMBOL_GPL(__inet_hash_connect).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
ffa30930d4ba630514fd93ded245456f05358140 diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 9cac6c0..e6a0072 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -494,7 +494,6 @@ out:
 		return ret;
 	}
 }
-EXPORT_SYMBOL_GPL(__inet_hash_connect);
 
 /*
  * Bind a port for a connect operation and hash it.

