From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/9] qlcnic: Bug fixes and enhancements
Date: Sat, 13 Apr 2013 13:28:25 -0400
Message-ID: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55165 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750940Ab3DMRwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Please apply to net-next.

Thanks,
Shahed

Himanshu Madhani (4):
  qlcnic: Implement GET_LED_STATUS command for 82xx adapter.
  qlcnic: Add identifying string for 83xx adapter
  qlcnic: fix beaconing test for 82xx adapter
  qlcnic: Enable Interrupt Coalescing for 83xx adapter

Manish Chopra (1):
  qlcnic: Enhanced channel configuration logs

Shahed Shaikh (2):
  qlcnic: Fix typo in logs
  qlcnic: Bump up the version to 5.2.41

Sony Chacko (1):
  qlcnic: Fix recurring firmware dump collection

Sritej Velaga (1):
  qlcnic: fix TSO race condition

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   25 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   24 +++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   72 ++++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   23 +++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    8 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   92 +++++++++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |   13 +++-
 10 files changed, 217 insertions(+), 45 deletions(-)
