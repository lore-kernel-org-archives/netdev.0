From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v2 net-next 0/2] qlge: feature update
Date: Thu, 29 Aug 2013 00:51:06 -0400
Message-ID: <1377751868-1367-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49073 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752398Ab3H2FT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 01:19:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

This patch series enhance the handling of nested vlan tags in Rx path.

V2 changes:
* removed module parameter. 

 
Please apply it to net-next.

Jitendra Kalsaria (2):
  qlge: Enhance nested VLAN (Q-in-Q) handling.
  qlge: Update version to 1.0.0.33

 drivers/net/ethernet/qlogic/qlge/qlge.h      |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |  142 ++++++++++----------------
 2 files changed, 54 insertions(+), 90 deletions(-)
