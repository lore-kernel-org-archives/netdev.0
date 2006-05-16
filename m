From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/802/tr.c: remove an unused export
Date: Tue, 16 May 2006 20:48:43 +0200
Message-ID: <20060516184843.GP10077@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59912 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751625AbWEPSsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 14:48:46 -0400
To: acme@conectiva.com.br
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the unused EXPORT_SYMBOL(tr_source_route).

(No, the usage in net/llc/llc_output.c can't be modular.)

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 20 Apr 2006

--- linux-2.6.17-rc1-mm3-full/net/802/tr.c.old	2006-04-20 22:45:07.000000000 +0200
+++ linux-2.6.17-rc1-mm3-full/net/802/tr.c	2006-04-20 22:45:18.000000000 +0200
@@ -643,6 +643,5 @@
 
 module_init(rif_init);
 
-EXPORT_SYMBOL(tr_source_route);
 EXPORT_SYMBOL(tr_type_trans);
 EXPORT_SYMBOL(alloc_trdev);


