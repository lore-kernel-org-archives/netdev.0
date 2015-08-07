From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/6] qlcnic: enhancements
Date: Fri, 7 Aug 2015 07:17:01 -0400
Message-ID: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32111 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbbHGMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 08:02:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi Dave,

This series adds few enhancements.

  o Patch from Harish reorders the sequence of header files inclusion,
    keeping kernel's header files on top.

  o Firmware introduced a new feature which allows driver to increases
    the size of firmware dump of iSCSI function which is being collected
    by NIC driver.

  o Print buffer address which is holding a firmware dump.

  o Use vzalloc() instead kzalloc() for allocating large chunk of memory
    which will avoid potential memory allocation failure.

  o Add new device ID for 0x8C30 which is a 83xx series based VF function.

Please apply this series to net-next.

Thanks,
Shahed

Harish Patil (1):
  qlcnic: Rearrange ordering of header files inclusion

Shahed Shaikh (5):
  qlcnic: Add support to enable capability to extend minidump for iSCSI
  qlcnic: Print firmware minidump buffer and template header addresses
  qlcnic: Add new VF device ID 0x8C30
  qlcnic: Don't use kzalloc unncecessarily for allocating large chunk
    of memory
  qlcnic: Update version to 5.3.63

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   19 +++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   31 ++++++++++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   14 ++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   41 ++++++++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    3 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    3 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |    7 +--
 12 files changed, 102 insertions(+), 32 deletions(-)
