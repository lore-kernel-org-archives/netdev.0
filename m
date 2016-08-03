From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 0/3] qlcnic: bug fixes
Date: Wed, 3 Aug 2016 04:02:01 -0400
Message-ID: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:38816 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757157AbcHCIot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 04:44:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series fixes a data structure corruption bug in
VF's async mailbox commands handling and an issue realted
to napi poll budget in the driver.

Please consider applying this series to "net"

Thanks,
Manish

Manish Chopra (3):
  qlcnic: fix data structure corruption in async mbx command handling
  qlcnic: fix napi budget alteration
  qlcnic: Update version to 5.3.65

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    9 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   95 +++++++++++--------
 4 files changed, 62 insertions(+), 48 deletions(-)
