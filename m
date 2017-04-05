From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: define SOL_PPPOL2TP in uapi
Date: Wed, 5 Apr 2017 16:52:35 +0200
Message-ID: <28884134c7944f005e4872256742b10765cc2770.1491402366.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:59410 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754726AbdDEOwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:52:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace needs SOL_PPPOL2TP to be defined for using PPPOL2TP_SO_*
socket options.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 include/uapi/linux/if_pppol2tp.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/if_pppol2tp.h b/include/uapi/linux/if_pppol2tp.h
index 6418c4d10241..90ce1abd2c4b 100644
--- a/include/uapi/linux/if_pppol2tp.h
+++ b/include/uapi/linux/if_pppol2tp.h
@@ -73,6 +73,8 @@ struct pppol2tpv3in6_addr {
 	struct sockaddr_in6 addr;	/* IP address and port to send to */
 };
 
+#define SOL_PPPOL2TP 273
+
 /* Socket options:
  * DEBUG	- bitmask of debug message categories
  * SENDSEQ	- 0 => don't send packets with sequence numbers
-- 
2.11.0
