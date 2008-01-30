From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make net/802/tr.c:sysctl_tr_rif_timeout static
Date: Wed, 30 Jan 2008 22:02:50 +0200
Message-ID: <20080130200250.GB29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40720 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755784AbYA3UCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:02:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysctl_tr_rif_timeout can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
e5accd81b924224d40a3f38204c08cf6896ed79b 
diff --git a/net/802/tr.c b/net/802/tr.c
index 3f16b17..18c6647 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -76,7 +76,7 @@ static DEFINE_SPINLOCK(rif_lock);
 
 static struct timer_list rif_timer;
 
-int sysctl_tr_rif_timeout = 60*10*HZ;
+static int sysctl_tr_rif_timeout = 60*10*HZ;
 
 static inline unsigned long rif_hash(const unsigned char *addr)
 {

