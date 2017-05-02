From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v3 net-next 05/11] ibmvnic: Whitespace correction in
 release_rx_pools
Date: Tue, 02 May 2017 14:52:41 -0400
Message-ID: <20170502185241.28214.32526.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54039 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751385AbdEBPED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:04:03 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42F3vvH003058
        for <netdev@vger.kernel.org>; Tue, 2 May 2017 11:04:02 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a6v8t0m9f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 11:04:02 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 2 May 2017 11:03:58 -0400
In-Reply-To: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
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
