From: Hal Rosenstock <hrosenstock@xsigo.com>
Subject: [PATCH][TRIVIAL] ibm_emac/ibm_emac_mal.c:mal_poll: Fix MAL_DBG2
	invocation
Date: Thu, 17 Jan 2008 10:47:15 -0800
Message-ID: <1200595635.25836.53.camel@hrosenstock-ws.xsigo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: ebs@ebshome.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.xsigo.com ([216.184.49.20]:45929 "EHLO mx01.xsigo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbYAQUHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 15:07:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ibm_emac/ibm_emac_mal.c:mal_poll: Fix MAL_DBG2 invocation

Signed-off-by: Hal Rosenstock <hal@xsigo.com>

diff --git a/drivers/net/ibm_emac/ibm_emac_mal.c b/drivers/net/ibm_emac/ibm_emac_mal.c
index dcd8826..1977791 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.c
+++ b/drivers/net/ibm_emac/ibm_emac_mal.c
@@ -279,7 +279,7 @@ static int mal_poll(struct napi_struct *napi, int budget)
 	struct list_head *l;
 	int received = 0;
 
-	MAL_DBG2("%d: poll(%d) %d ->" NL, mal->def->index, *budget,
+	MAL_DBG2("%d: poll(%d) %d ->" NL, mal->def->index, budget,
 		 rx_work_limit);
       again:
 	/* Process TX skbs */

