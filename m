From: Karen Xie <kxie@chelsio.com>
Subject: [RFC][PATCH 0/1] cxgb3i: cxgb3 iSCSI initiator
Date: Tue, 29 Jul 2008 17:19:25 -0700
Message-ID: <200807300019.m6U0JPa1012550@localhost.localdomain>
Cc: jgarzik@pobox.com, davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com
To: netdev@vger.kernel.org, open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8039 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbYG3AKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 20:10:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone,

Please review our new version of the iSCSI Initiator drivers for Chelsio S3 adapters. The cxgb3i driver provides iscsi acceleration (PDU digest offload and payload direct-placement) to the open-iscsi initiator. It accesses the hardware through the cxgb3 module.

netdev list, please review cxgb3i_offload.[ch] which handles the iscsi connection APIs to the adapter.

The cxgb3i driver depends on the changes in Mike Christie's branch.

Thanks.
Karen
