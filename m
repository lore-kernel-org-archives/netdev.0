From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport sysctl_tcp_tso_win_divisor
Date: Wed, 30 Jan 2008 22:02:32 +0200
Message-ID: <20080130200232.GU29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51745 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758381AbYA3UB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:01:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no longer used 
EXPORT_SYMBOL(sysctl_tcp_tso_win_divisor).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
4884e7997ba5f63f2efeaeead21ed2768fb3f4de 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 89f0188..ed750f9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2564,5 +2564,4 @@ EXPORT_SYMBOL(tcp_connect);
 EXPORT_SYMBOL(tcp_make_synack);
 EXPORT_SYMBOL(tcp_simple_retransmit);
 EXPORT_SYMBOL(tcp_sync_mss);
-EXPORT_SYMBOL(sysctl_tcp_tso_win_divisor);
 EXPORT_SYMBOL(tcp_mtup_init);

