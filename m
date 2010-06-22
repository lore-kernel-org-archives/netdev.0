From: frank.blaschka@de.ibm.com
Subject: [patch 05/11] [PATCH] qeth: Fold qeth_sense debug area
Date: Tue, 22 Jun 2010 10:57:06 +0200
Message-ID: <20100622085807.529076000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:41957 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758948Ab0FVI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:09 -0400
Content-Disposition: inline; filename=605-qeth-sense-debug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch removes the sense debug area completely. Despite the name this
debug area makes no sense at all because it's unused completely. Ouch.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 -
 drivers/s390/net/qeth_core_main.c |    2 --
 2 files changed, 3 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:54:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:54:59.000000000 +0200
@@ -42,7 +42,6 @@ enum qeth_dbf_names {
 	QETH_DBF_SETUP,
 	QETH_DBF_QERR,
 	QETH_DBF_MSG,
-	QETH_DBF_SENSE,
 	QETH_DBF_MISC,
 	QETH_DBF_CTRL,
 	QETH_DBF_INFOS	/* must be last element */
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:59.000000000 +0200
@@ -36,8 +36,6 @@ struct qeth_dbf_info qeth_dbf[QETH_DBF_I
 				2, 1,   8, 2, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_MSG]   = {"qeth_msg",
 				8, 1, 128, 3, &debug_sprintf_view,   NULL},
-	[QETH_DBF_SENSE] = {"qeth_sense",
-				2, 1,  64, 2, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_MISC]	 = {"qeth_misc",
 				2, 1, 256, 2, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_CTRL]  = {"qeth_control",

