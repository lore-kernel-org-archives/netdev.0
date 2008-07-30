From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 30 Jul 2008 11:37:08 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334032EC742@maui.asicdesigners.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain> <46A00B48CC54E4468EF6911F877AC4CA01839662@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <davem@davemloft.net>, <michaelc@cs.wisc.edu>,
	"Steve Wise" <swise@opengridcomputing.com>, <rdreier@cisco.com>,
	<daisyc@us.ibm.com>, <wenxiong@us.ibm.com>, <bhua@us.ibm.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>
To: <open-iscsi@googlegroups.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11039 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbYG3Sk3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 14:40:29 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Shyam,

The define is already in the cxgb3i branch of the iscsi git tree, so I
did not include it here. 
This particular patch contains the connection offload part which we'd
like to get reviewed by the netdev list.

Thanks.
Karen

-----Original Message-----
From: open-iscsi@googlegroups.com [mailto:open-iscsi@googlegroups.com]
On Behalf Of Shyam_Iyer@Dell.com
Sent: Wednesday, July 30, 2008 11:16 AM
To: open-iscsi@googlegroups.com; netdev@vger.kernel.org
Cc: jgarzik@pobox.com; davem@davemloft.net; michaelc@cs.wisc.edu; Steve
Wise; rdreier@cisco.com; daisyc@us.ibm.com; wenxiong@us.ibm.com;
bhua@us.ibm.com; Divy Le Ray; Dimitrios Michailidis; Casey Leedom
Subject: RE: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator


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

--~--~---------~--~----~------------~-------~--~----~
You received this message because you are subscribed to the Google
Groups "open-iscsi" group.
To post to this group, send email to open-iscsi@googlegroups.com
To unsubscribe from this group, send email to
open-iscsi+unsubscribe@googlegroups.com
For more options, visit this group at
http://groups.google.com/group/open-iscsi
-~----------~----~----~----~------~----~------~--~---

