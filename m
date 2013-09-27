From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v3 net-next 0/2] qlge: feature update
Date: Fri, 27 Sep 2013 13:17:45 -0400
Message-ID: <1380302267-27843-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45747 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752384Ab3I0Rrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 13:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

This patch series enhance the handling of nested vlan tags in Rx path.

V2 changes:
* removed module parameter.

V3 changes:
* Users can enable or disable hardware VLAN acceleration using ethtool

Please apply it to net-next.

Jitendra Kalsaria (2):
  qlge: Enhance nested VLAN (Q-in-Q) handling.
  qlge: Update version to 1.00.00.33

 drivers/net/ethernet/qlogic/qlge/qlge.h      |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |  126 +++++++++++++++++++++-----
 2 files changed, 102 insertions(+), 26 deletions(-)

-- 
1.7.6.rc1.1.g2c162b
