From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/5] qlcnic: bug fixes and feature updates
Date: Fri,  8 Mar 2013 14:53:48 -0500
Message-ID: <1362772433-12045-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45422 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756158Ab3CHUQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 15:16:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Please apply to net-next.

Thanks,
Shahed

Himanshu Madhani (1):
  qlcnic: Enable LED test support for 83xx adapter

Shahed Shaikh (4):
  qlcnic: Fix endianness issues in 83xx driver
  qlcnic: Fix ethtool statistics for 82xx adapter
  qlcnic: Fix ethtool statistics collection
  qlcnic: Bump up the version to 5.1.36

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  151 +++++++++++++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   18 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   33 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   14 +-
 5 files changed, 186 insertions(+), 34 deletions(-)
