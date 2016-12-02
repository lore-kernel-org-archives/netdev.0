From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/3] uapi: export tc tunnel key file
Date: Fri,  2 Dec 2016 14:50:48 -0800
Message-ID: <20161202225050.30048-2-sthemmin@microsoft.com>
References: <20161202225050.30048-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36247 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754390AbcLBW6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:58:33 -0500
Received: by mail-pf0-f171.google.com with SMTP id 189so54825622pfz.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:58:33 -0800 (PST)
In-Reply-To: <20161202225050.30048-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes commit 21609ae32aaf6c6fab0e ("net/sched: Introduce act_tunnel_key")
The file is necessary for iproute2 headers but was not being
copied by make install_headers

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/uapi/linux/tc_act/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index e3969bd..9611c7b 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -11,3 +11,4 @@ header-y += tc_vlan.h
 header-y += tc_bpf.h
 header-y += tc_connmark.h
 header-y += tc_ife.h
+header-y += tc_tunnel_key.h
-- 
2.10.2
