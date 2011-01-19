From: kaber@trash.net
Subject: [PATCH 19/79] IPVS: buffer argument to ip_vs_process_message() should not be const
Date: Wed, 19 Jan 2011 20:14:19 +0100
Message-ID: <1295464519-21763-20-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51976 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495Ab1ASTP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:27 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

It is assigned to a non-const variable and its contents are modified.

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 72b3d88..3897d6b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -303,7 +303,7 @@ ip_vs_conn_fill_param_sync(int af, int protocol,
  *      Process received multicast message and create the corresponding
  *      ip_vs_conn entries.
  */
-static void ip_vs_process_message(const char *buffer, const size_t buflen)
+static void ip_vs_process_message(char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
 	struct ip_vs_sync_conn *s;
-- 
1.7.2.3

