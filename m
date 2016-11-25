From: Julian Wollrath <jwollrath@web.de>
Subject: [PATCH] Set DEFAULT_TCP_CONG to bbr if DEFAULT_BBR is set
Date: Fri, 25 Nov 2016 15:05:26 +0100
Message-ID: <20161125140526.2486-1-jwollrath@web.de>
Cc: Julian Wollrath <jwollrath@web.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:65251 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754566AbcKYOGY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 09:06:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Julian Wollrath <jwollrath@web.de>
---
 net/ipv4/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 300b06888fdf..b54b3ca939db 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -715,6 +715,7 @@ config DEFAULT_TCP_CONG
 	default "reno" if DEFAULT_RENO
 	default "dctcp" if DEFAULT_DCTCP
 	default "cdg" if DEFAULT_CDG
+	default "bbr" if DEFAULT_BBR
 	default "cubic"
 
 config TCP_MD5SIG
-- 
2.10.2
