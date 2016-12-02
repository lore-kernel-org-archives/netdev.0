From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 2/3] uapi: export tc_skbmod.h
Date: Fri,  2 Dec 2016 14:50:49 -0800
Message-ID: <20161202225050.30048-3-sthemmin@microsoft.com>
References: <20161202225050.30048-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35371 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753224AbcLBW62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:58:28 -0500
Received: by mail-pg0-f47.google.com with SMTP id p66so112174284pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:58:28 -0800 (PST)
In-Reply-To: <20161202225050.30048-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes commit 735cffe5d800 ("net_sched: Introduce skbmod action")
Not used by iproute2 but maybe in future.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/uapi/linux/tc_act/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index 9611c7b..721433e 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -12,3 +12,4 @@ header-y += tc_bpf.h
 header-y += tc_connmark.h
 header-y += tc_ife.h
 header-y += tc_tunnel_key.h
+header-y += tc_sbkmod.h
-- 
2.10.2
