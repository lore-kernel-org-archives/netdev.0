From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 3/3] uapi: export nf_log.h
Date: Fri,  2 Dec 2016 14:54:00 -0800
Message-ID: <20161202225400.32751-4-sthemmin@microsoft.com>
References: <20161202225400.32751-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34021 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753075AbcLBWyH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:54:07 -0500
Received: by mail-pg0-f45.google.com with SMTP id x23so112140677pgx.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:54:07 -0800 (PST)
In-Reply-To: <20161202225400.32751-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

File is in uapi directory but not being copied on
 make install_headers

Fixes commit 4ec9c8fbbc22 ("netfilter: nft_log: complete
NFTA_LOG_FLAGS attr support").

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/uapi/linux/netfilter/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index cd26d7a..03f194a 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -5,6 +5,7 @@ header-y += nf_conntrack_ftp.h
 header-y += nf_conntrack_sctp.h
 header-y += nf_conntrack_tcp.h
 header-y += nf_conntrack_tuple_common.h
+header-y += nf_log.h
 header-y += nf_tables.h
 header-y += nf_tables_compat.h
 header-y += nf_nat.h
-- 
2.10.2
