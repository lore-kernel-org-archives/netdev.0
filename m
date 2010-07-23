From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] iproute2: use get_user_hz() for IPv6 print_route
Date: Fri, 23 Jul 2010 15:37:31 +0200
Message-ID: <20100723133731.GB12942@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-51.dex002.intermedia.net ([64.78.21.150]:59018 "EHLO
	DHOST002-51.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754718Ab0GWNlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:41:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as already done in IPv4 and metrics code part

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 ip/iproute.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index fce7f33..04b253a 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -482,7 +482,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (mxrta[i] == NULL)
 				continue;
 			if (!hz)
-				hz = get_hz();
+				hz = get_user_hz();
 
 			if (i < sizeof(mx_names)/sizeof(char*) && mx_names[i])
 				fprintf(fp, " %s", mx_names[i]);
-- 
1.7.0.4

