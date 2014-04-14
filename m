From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/6] qlcnic: Bug fixes
Date: Mon, 14 Apr 2014 10:02:17 -0400
Message-ID: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46899 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751007AbaDNOjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:39:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series contains following bug fixes -

* Send INIT_NIC_FUNC mailbox command as first mailbox
* Fix a panic because of uninitialized delayed_work.
* Fix inconsistent calculation of max rings count.
* Fix PVID configuration issue. Driver needs to clear older
  PVID before adding new one.
* Fix QLogic application/driver interface by packing vNIC information
  array.
* Fix a crash when user tries to disable SR-IOV while VFs are
  still assigned to VMs.

Please apply to net.

Thanks,
Shahed


Jitendra Kalsaria (2):
  qlcnic: Fix PVID configuration on eSwitch port.
  qlcnic: Fix QLogic application/driver interface for virtual NIC
    configuration

Manish Chopra (1):
  qlcnic: Do not disable SR-IOV when VFs are assigned to VMs

Shahed Shaikh (1):
  qlcnic: Fix max ring count calculation

Sucheta Chakraborty (2):
  qlcnic: Fix panic due to uninitialzed delayed_work struct in use.
  qlcnic: Fix to send INIT_NIC_FUNC as first mailbox.

 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 21 ++++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  3 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    |  2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  5 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 10 +++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 31 ++++++++++++----------
 6 files changed, 43 insertions(+), 29 deletions(-)

-- 
1.8.1.4
