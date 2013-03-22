From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/5] qlcnic: bug fixes and log enhancement
Date: Fri, 22 Mar 2013 11:57:52 -0400
Message-ID: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:28307 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754313Ab3CVQUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:20:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Please apply to net-next.

Thanks,
Shahed

Himanshu Madhani (1):
  qlcnic: Log warning message for 83xx adapter in MSI mode.

Manish chopra (1):
  qlcnic: Fix configure mailbox interrupt command for 83xx adapter

Shahed Shaikh (3):
  qlcnic: change mdelay to msleep
  qlcnic: Clear link status when interface is down
  qlcnic: Bump up the version to 5.1.38

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    3 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    7 +++++++
 4 files changed, 11 insertions(+), 5 deletions(-)
