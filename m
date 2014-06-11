From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/3] qlcnic: Enhancement and optimization
Date: Wed, 11 Jun 2014 14:09:10 -0400
Message-ID: <1402510153-9928-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57846 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754096AbaFKSjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 14:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This series contains an enhancement in the area of firmware minidump collection
and optimization of ring count validation function.

Please apply this series to net-next.

Thanks,
Shahed

Shahed Shaikh (3):
  qlcnic: Pre-allocate DMA buffer used for minidump collection
  qlcnic: Optimize ring count validations
  qlcnic: Update version to 5.3.60

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  6 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  9 ++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 24 ++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   | 32 ++++++++++------------
 4 files changed, 37 insertions(+), 34 deletions(-)

-- 
1.8.1.4
