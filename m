From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] net: Document xfrm4_gc_thresh and xfrm6_gc_thresh
Date: Mon, 17 Aug 2015 21:58:21 +0200
Message-ID: <1439841501-20990-5-git-send-email-steffen.klassert@secunet.com>
References: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55672 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbbHQT6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 15:58:39 -0400
In-Reply-To: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change adds documentation for xfrm4_gc_thresh and xfrm6_gc_thresh
based on the comments in commit eeb1b73378b56 ("xfrm: Increase the garbage
collector threshold").

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 Documentation/networking/ip-sysctl.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 56db1ef..46e88ed 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1181,6 +1181,11 @@ tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
 
+xfrm4_gc_thresh - INTEGER
+	The threshold at which we will start garbage collecting for IPv4
+	destination cache entries.  At twice this value the system will
+	refuse new allocations.
+
 Alexey Kuznetsov.
 kuznet@ms2.inr.ac.ru
 
@@ -1617,6 +1622,11 @@ ratelimit - INTEGER
 	otherwise the minimal space between responses in milliseconds.
 	Default: 1000
 
+xfrm6_gc_thresh - INTEGER
+	The threshold at which we will start garbage collecting for IPv6
+	destination cache entries.  At twice this value the system will
+	refuse new allocations.
+
 
 IPv6 Update by:
 Pekka Savola <pekkas@netcore.fi>
-- 
1.9.1
