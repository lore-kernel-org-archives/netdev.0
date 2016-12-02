From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/3] uapi: export tc tunnel key file
Date: Fri,  2 Dec 2016 14:53:58 -0800
Message-ID: <20161202225400.32751-2-sthemmin@microsoft.com>
References: <20161202225400.32751-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33109 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752895AbcLBWyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:54:04 -0500
Received: by mail-pg0-f51.google.com with SMTP id 3so112138531pgd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:54:04 -0800 (PST)
In-Reply-To: <20161202225400.32751-1-sthemmin@microsoft.com>
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
