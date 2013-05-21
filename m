From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/3]  qlcnic: Bug fixes
Date: Tue, 21 May 2013 15:26:58 -0400
Message-ID: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:37325 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751769Ab3EUTwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 15:52:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series includes following bug fixes:
* Fix probe failure path by returning proper error codes.
* Removed access to netdev->trans_start in driver.
* Fix netdev->features manipulation as part of change in EPORT
  features

Please apply to net.

Thanks,
Shahed

Shahed Shaikh (1):
  qlcnic: Fix updating netdev->features

Sony Chacko (2):
  qlcnic: Return proper error codes from probe failure paths
  qlcnic: remove netdev->trans_start updates within the driver

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    6 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   49 ++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   65 +++++---------------
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |    3 +
 6 files changed, 70 insertions(+), 56 deletions(-)
