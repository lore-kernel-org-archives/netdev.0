From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/3] qlcnic: Bug fixes
Date: Thu, 18 Apr 2013 14:10:03 -0400
Message-ID: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:63137 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751419Ab3DRSdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 14:33:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series contains bug fixes for -
* Loopback test failure while traffic is running.
* Tx timeout and subsequent firmware reset by removing check for
  '(adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)' from tx fast
  path, as per Eric's suggestion.
* Typo in logs.

Please apply to net.

Thanks,
Shahed

Jitendra Kalsaria (1):
  qlcnic: Stop traffic before performing loopback test

Shahed Shaikh (1):
  qlcnic: Fix typo in logs

Sritej Velaga (1):
  qlcnic: fix TSO race condition

 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   15 ++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    3 +--
 2 files changed, 11 insertions(+), 7 deletions(-)
