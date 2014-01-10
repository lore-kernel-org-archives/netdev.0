From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/8] qlcnic driver updates
Date: Fri, 10 Jan 2014 11:48:51 -0500
Message-ID: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:28701 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751306AbaAJRWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:22:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This series includes following changes:
o SRIOV and VLAN filtering related enhancements which includes
   - Do MAC learning for PF
   - Restrict VF from configuring any VLAN mode
   - Enable flooding on PF
   - Turn on promiscuous mode for PF

o Bug fix in qlcnic_sriov_cleanup() introduced by commit
  154d0c81("qlcnic: VLAN enhancement for 84XX adapters")

o Beaconing support for 83xx and 84xx series adapters

o Allow 82xx adapter to perform IPv6 LRO even if destination IP address is not
  programmed.


Please apply this series to net-next.

Thanks,
Shahed

Himanshu Madhani (1):
  qlcnic: Enable beaconing for 83xx/84xx Series adapter.

Manish Chopra (1):
  qlcnic: Fix SR-IOV cleanup code path

Shahed Shaikh (2):
  qlcnic: Enable IPv6 LRO even if IP address is not programmed
  qlcnic: Update version to 5.3.54

Sucheta Chakraborty (4):
  qlcnic: Restrict VF from configuring any VLAN mode.
  qlcnic: Enable VF flood bit on PF.
  qlcnic: Turn on promiscous mode for SRIOV PF.
  qlcnic: Do MAC learning for SRIOV PF.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 15 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 35 +++++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  3 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |  8 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     | 38 +++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 80 ++++++++++++++--------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  1 +
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 42 +++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 17 ++---
 12 files changed, 183 insertions(+), 62 deletions(-)

-- 
1.8.3.1
