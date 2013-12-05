From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 0/3] qlge: Bug fixes
Date: Thu, 5 Dec 2013 18:11:21 -0500
Message-ID: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:8193 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756030Ab3LEXn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:43:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

This patch series include bug fixes.
o Receive frame error stats were getting overwritten by other driver statistics.
o User is allowed to enable/disable rx/tx vlan acceleration independently.

Jitendra Kalsaria (3):
  qlge: Fix ethtool statistics
  qlge: Allow enable/disable rx/tx vlan acceleration independently
  qlge: Update version to 1.00.00.34

 drivers/net/ethernet/qlogic/qlge/qlge.h         |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    4 ++++
 drivers/net/ethernet/qlogic/qlge/qlge_main.c    |    8 --------
 3 files changed, 5 insertions(+), 9 deletions(-)

-- 
1.7.6.rc1.1.g2c162b
