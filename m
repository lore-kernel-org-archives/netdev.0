From: <Shyam_Iyer@Dell.com>
Subject: RE: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 30 Jul 2008 23:45:36 +0530
Message-ID: <46A00B48CC54E4468EF6911F877AC4CA01839662@blrx3m10.blr.amer.dell.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <davem@davemloft.net>, <michaelc@cs.wisc.edu>,
	<swise@opengridcomputing.com>, <rdreier@cisco.com>,
	<daisyc@us.ibm.com>, <wenxiong@us.ibm.com>, <bhua@us.ibm.com>,
	<divy@chelsio.com>, <dm@chelsio.com>, <leedom@chelsio.com>
To: <open-iscsi@googlegroups.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:39898 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbYG3SPl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 14:15:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200807300019.m6U0JkdY012558@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+
+static struct iscsi_transport cxgb3i_iscsi_transport = {
+	.owner = THIS_MODULE,
+	.name = "cxgb3i",
+	.caps = CAP_RECOVERY_L0 | CAP_MULTI_R2T | CAP_HDRDGST
+	    | CAP_DATADGST | CAP_DIGEST_OFFLOAD,

Correct me if I am wrong but possibly CAP_DATA_OFFLOAD needs to be added
here for including PDU Offload capability into the adapter. I am trying
to correlate with the open-iscsi userspace code currently upstream.

Thanks,
Shyam Iyer
