From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 05/11] ibmvnic: Whitespace correction in
 release_rx_pools
Date: Mon, 01 May 2017 17:57:08 -0400
Message-ID: <20170501215708.27224.4540.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38885 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751150AbdEASIX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:08:23 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v41I4GDp103269
        for <netdev@vger.kernel.org>; Mon, 1 May 2017 14:08:22 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a68vvk32j-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 14:08:22 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Mon, 1 May 2017 14:08:21 -0400
In-Reply-To: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 9f2686d..d20d884 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -348,7 +348,7 @@ static void release_rx_pools(struct ibmvnic_adapter *adapter)
 		free_long_term_buff(adapter, &rx_pool->long_term_buff);
 
 		if (!rx_pool->rx_buff)
-		continue;
+			continue;
 
 		for (j = 0; j < rx_pool->size; j++) {
 			if (rx_pool->rx_buff[j].skb) {
