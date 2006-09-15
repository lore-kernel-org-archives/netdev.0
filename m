From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/9] s390: Makefile cleanup
Date: Fri, 15 Sep 2006 16:25:39 +0200
Message-ID: <20060915142539.GC10043@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:26518 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751547AbWIOOhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 10:37:12 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8FEbBl0180710
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:37:11 +0100
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8FEdMHq1703974
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:39:22 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8FEbAmu022720
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 15:37:11 +0100
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 3/9] s390: Makefile cleanup

From: Frank Pavlic <fpavlic@de.ibm.com>
 	remove CONFIG_MPC from Makefile which was
	introduced accidently in the past.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/Makefile |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

bf825354b9a1839f8923d11a3b1b634fcc013c35
diff --git a/drivers/s390/net/Makefile b/drivers/s390/net/Makefile
index 6775a83..4777e36 100644
--- a/drivers/s390/net/Makefile
+++ b/drivers/s390/net/Makefile
@@ -10,7 +10,6 @@ obj-$(CONFIG_SMSGIUCV) += smsgiucv.o
 obj-$(CONFIG_CTC) += ctc.o fsm.o cu3088.o
 obj-$(CONFIG_LCS) += lcs.o cu3088.o
 obj-$(CONFIG_CLAW) += claw.o cu3088.o
-obj-$(CONFIG_MPC) += ctcmpc.o fsm.o cu3088.o
 qeth-y := qeth_main.o qeth_mpc.o qeth_sys.o qeth_eddp.o 
 qeth-$(CONFIG_PROC_FS) += qeth_proc.o
 obj-$(CONFIG_QETH) += qeth.o
-- 
1.2.4

