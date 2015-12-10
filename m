From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] uapi: export ila.h
Date: Thu, 10 Dec 2015 09:14:20 -0800
Message-ID: <20151210091420.3e785232@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33712 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbbLJRON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 12:14:13 -0500
Received: by pfnn128 with SMTP id n128so50978438pfn.0
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 09:14:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The file ila.h used for lightweight tunnels is being used by iproute2
but is not exported yet.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/uapi/linux/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 628e6e6..c2e5d6c 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -186,6 +186,7 @@ header-y += if_tunnel.h
 header-y += if_vlan.h
 header-y += if_x25.h
 header-y += igmp.h
+header-y += ila.h
 header-y += in6.h
 header-y += inet_diag.h
 header-y += in.h
-- 
2.1.4
