From: fpavlic@de.ibm.com
Subject: [PATCH 3/9] s390: Makefile cleanup
Date: Wed, 6 Sep 2006 17:05:19 +0200
Message-ID: <200609061705.19420.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:64636 "EHLO
	mtagate6.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751250AbWIFPEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:04:23 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id k86F4Msk139412
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:04:22 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F8kII2228386
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 17:08:46 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F4Lu6024010
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 17:04:21 +0200
To: Jeff Garzik <jgarzik@pobox.com>
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

