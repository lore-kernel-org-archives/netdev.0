From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 0/6] qlcnic driver updates
Date: Fri, 25 Apr 2014 17:43:55 -0400
Message-ID: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62547 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751400AbaDYWV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 18:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

This patch series containes following changes -
* Optimize MAC learning code.
* Export board temperature using hwmon-sysfs interface.
* Add support for configuring Tx interrupt coalescing parameters from VF.
* Logging error messages in error path.
* Restrict extended vNIC support in legacy interrupt mode and log appropriate
  message.

Please apply this series to net-next.

Thanks,
Jiten

Harish Patil (1):
  qlcnic: Add hwmon-sysfs interface to export board temperature.

Jitendra Kalsaria (1):
  qlcnic: Update version to 5.3.58

Shahed Shaikh (1):
  qlcnic: Optimize MAC learning code

Sucheta Chakraborty (3):
  qlcnic: Allow setting TX interrupt coalescing parameters from VF.
  qlcnic: Add driver logs in error path.
  qlcnic: Limit VNIC support in legacy interrupt mode

 drivers/net/ethernet/qlogic/Kconfig                | 11 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 19 +++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 13 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 13 ++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 19 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 25 +++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 35 +++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 68 ++++++++++++++++++++++
 9 files changed, 179 insertions(+), 26 deletions(-)

-- 
1.8.1.4
