From: kaber@trash.net
Subject: [PATCH] netfilter: xtables: remove extraneous header that slipped in
Date: Thu, 20 Jan 2011 08:58:02 +0100
Message-ID: <1295510282-16860-2-git-send-email-kaber@trash.net>
References: <1295510282-16860-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62797 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab1ATH6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 02:58:05 -0500
In-Reply-To: <1295510282-16860-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Commit 0b8ad87 (netfilter: xtables: add missing header files to export
list) erroneously added this.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index fc4e0aa..89c0d1e 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -56,7 +56,6 @@ header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
 header-y += xt_sctp.h
-header-y += xt_secmark.h
 header-y += xt_socket.h
 header-y += xt_state.h
 header-y += xt_statistic.h
-- 
1.7.2.3

