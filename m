From: kaber@trash.net
Subject: [PATCH 39/72] netfilter: install missing ebtables headers for userspace
Date: Thu, 21 Oct 2010 17:19:26 +0200
Message-ID: <1287674399-31455-40-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932Ab0JUPUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:10 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Bowler <nbowler@elliptictech.com>

The ebt_ip6.h and ebt_nflog.h headers are not not known to Kbuild and
therefore not installed by make headers_install.  Fix that up.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_bridge/Kbuild |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter_bridge/Kbuild b/include/linux/netfilter_bridge/Kbuild
index d4d7867..e48f1a3 100644
--- a/include/linux/netfilter_bridge/Kbuild
+++ b/include/linux/netfilter_bridge/Kbuild
@@ -3,11 +3,13 @@ header-y += ebt_among.h
 header-y += ebt_arp.h
 header-y += ebt_arpreply.h
 header-y += ebt_ip.h
+header-y += ebt_ip6.h
 header-y += ebt_limit.h
 header-y += ebt_log.h
 header-y += ebt_mark_m.h
 header-y += ebt_mark_t.h
 header-y += ebt_nat.h
+header-y += ebt_nflog.h
 header-y += ebt_pkttype.h
 header-y += ebt_redirect.h
 header-y += ebt_stp.h
-- 
1.7.1

