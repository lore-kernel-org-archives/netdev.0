From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH net-next] net/l2tp: fix build error in l2tp from missing ipv6 checksum include
Date: Mon, 30 Apr 2012 13:24:02 -0400
Message-ID: <20120430172402.GL17021@kvack.org>
References: <20120430155836.44bcf3846c80cf686bb9cb77@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:41714 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755228Ab2D3RYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 13:24:06 -0400
Content-Disposition: inline
In-Reply-To: <20120430155836.44bcf3846c80cf686bb9cb77@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Can you please verify if the patch below fixes the issue?  Thanks.

		-ben
----
net/l2tp: fix build error in l2tp from missing ipv6 checksum include

L2TP needs to ensure the IPv6 checksum helpers are included.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index e91d559..0ca9bc3 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -56,6 +56,7 @@
 #include <net/inet6_connection_sock.h>
 #include <net/inet_ecn.h>
 #include <net/ip6_route.h>
+#include <net/ip6_checksum.h>
 
 #include <asm/byteorder.h>
 #include <linux/atomic.h>
