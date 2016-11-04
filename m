From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 2/7] man: ip-l2tp.8: remove non-existent tunnel parameter name
Date: Fri,  4 Nov 2016 23:11:06 +0000
Message-ID: <20161104231111.14677-2-asbjorn@asbjorn.st>
References: <20161104231111.14677-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:46390 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752864AbcKDXLs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 19:11:48 -0400
In-Reply-To: <20161104231111.14677-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name parameter is only valid for sessions, not tunnels.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 man/man8/ip-l2tp.8 | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 4a3bb20..991d097 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -154,9 +154,6 @@ tunnels and sessions to be established and provides for detecting and
 acting upon network failures.
 .SS ip l2tp add tunnel - add a new tunnel
 .TP
-.BI name " NAME "
-sets the session network interface name. Default is l2tpethN.
-.TP
 .BI tunnel_id " ID"
 set the tunnel id, which is a 32-bit integer value. Uniquely
 identifies the tunnel. The value used must match the peer_tunnel_id
-- 
2.10.1
