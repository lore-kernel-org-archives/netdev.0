From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/3] qlcnic: Bug fixes
Date: Mon, 18 Aug 2014 09:31:52 -0400
Message-ID: <1408368715-8048-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:28850 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660AbaHROEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 10:04:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi Dave,

This series fixes some bugs related to endianess.

Please apply this series to net.

Thanks,
Shahed

Jitendra Kalsaria (1):
  qlcnic: Fix flash access interface to application

Rajesh Borundia (1):
  qlcnic: Fix endianess issue in FW dump template header

Shahed Shaikh (1):
  qlcnic: Fix endianess issue in firmware load from file operation

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   15 +++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    6 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   35 +++++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   57 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |   16 +++++-
 5 files changed, 114 insertions(+), 15 deletions(-)
