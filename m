From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] fix LL_MAX_HEADER for CONFIG_TR_MODULE
Date: Mon, 27 Apr 2009 12:32:07 +0300
Message-ID: <20090427093207.GB9259@localhost.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.welho.com ([213.243.153.39]:38490 "EHLO smtp5.welho.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbZD0Jbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 05:31:40 -0400
Received: from localhost.pp.htv.fi (cs181212059.pp.htv.fi [82.181.212.59])
	by smtp5.welho.com (Postfix) with ESMTP id 737EC5BC017
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 12:31:39 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unless I miss anything this should fix a bug.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..453be9a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -104,7 +104,7 @@ struct wireless_dev;
 # else
 #  define LL_MAX_HEADER 96
 # endif
-#elif defined(CONFIG_TR)
+#elif defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
 # define LL_MAX_HEADER 48
 #else
 # define LL_MAX_HEADER 32

