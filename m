From: frank.blaschka@de.ibm.com
Subject: [patch 10/11] [PATCH] qeth: specify correct function level for OSN devices
Date: Tue, 22 Jun 2010 10:57:11 +0200
Message-ID: <20100622085808.185985000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:59138 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758960Ab0FVI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:10 -0400
Content-Disposition: inline; filename=610-qeth-osn-function-level.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

OSN devices use the same function level as OSD devices. This patch
adds OSN-devices to the initialization function for func_level.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    1 +
 1 file changed, 1 insertion(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:02.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:02.000000000 +0200
@@ -1390,6 +1390,7 @@ static void qeth_init_func_level(struct 
 				QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT;
 		break;
 	case QETH_CARD_TYPE_OSD:
+	case QETH_CARD_TYPE_OSN:
 		card->info.func_level = QETH_IDX_FUNC_LEVEL_OSD;
 		break;
 	default:

