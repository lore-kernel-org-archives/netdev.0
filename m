From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Elide fib_validate_source() completely when
 possible.
Date: Sat, 30 Jun 2012 22:39:43 -0700 (PDT)
Message-ID: <20120630.223943.43292530650353283.davem@davemloft.net>
References: <20120629.020552.2190372012516348013.davem@davemloft.net>
	<alpine.LFD.2.00.1206301300530.1593@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab2GAFjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 01:39:46 -0400
In-Reply-To: <alpine.LFD.2.00.1206301300530.1593@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 30 Jun 2012 13:45:52 +0300 (EEST)

> 	If we really want a change in behavior we should
> at least update the accept_local info in
> Documentation/networking/ip-sysctl.txt ?

Thanks for pointing this out, that's what I will do.

====================
ipv4: Clarify in docs that accept_local requires rp_filter.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 Documentation/networking/ip-sysctl.txt |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 99d0e05..47b6c79 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -857,9 +857,14 @@ accept_source_route - BOOLEAN
 		FALSE (host)
 
 accept_local - BOOLEAN
-	Accept packets with local source addresses. In combination with
-	suitable routing, this can be used to direct packets between two
-	local interfaces over the wire and have them accepted properly.
+	Accept packets with local source addresses. In combination
+	with suitable routing, this can be used to direct packets
+	between two local interfaces over the wire and have them
+	accepted properly.
+
+	rp_filter must be set to a non-zero value in order for
+	accept_local to have an effect.
+
 	default FALSE
 
 route_localnet - BOOLEAN
-- 
1.7.10.4
