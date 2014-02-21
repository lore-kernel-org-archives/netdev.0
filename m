From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/7] qlcnic: Re-factoring and enhancements
Date: Fri, 21 Feb 2014 08:19:48 -0500
Message-ID: <1392988795-19380-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53986 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932239AbaBUNzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 08:55:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series includes following changes -
* Re-factored firmware minidump template header handling
* Support to make 8 vNIC mode application to work with 16 vNIC mode
* Enhance error message logging when adapter is in failed state and
  when adapter lock access fails.
* Allow vlan0 traffic
* update MAINTAINERS

Please apply this series to net-next.

Thanks,
Shahed

Harish Patil (1):
  qlcnic: Enhance semaphore lock access failure error message

Jitendra Kalsaria (1):
  qlcnic: Updates to QLogic application/driver interface for virtual NIC
    configuration

Rajesh Borundia (1):
  qlcnic: Allow vlan0 traffic

Shahed Shaikh (3):
  qlcnic: Re-factor firmware minidump template header handling
  qlcnic: Update version to 5.3.56
  Update MAINTAINERS for qlcnic driver

Sucheta Chakraborty (1):
  qlcnic: Enhance driver message in failed state.

 MAINTAINERS                                        |   7 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  77 ++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   7 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   8 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  17 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  22 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   8 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  11 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   | 233 ++++++++++++++++-----
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 102 ++++-----
 11 files changed, 349 insertions(+), 149 deletions(-)

-- 
1.8.1.4
