From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/6] qlcnic: Feature addition and enhancements
Date: Wed, 27 Aug 2014 12:43:16 -0400
Message-ID: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:43602 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932511AbaH0RQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:16:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi Dave,

This series contains following feature addition and enhancements,
- Update Link speed and Port type information for 83xx series adapters
- Support 0x8830 device ID
- Support for Power on Self Test (POST) feature for 83xx
- Use usleep_range() instead of msleep() for values less than 20ms

Please apply this series to net-next.

Thanks,
Shahed

Jitendra Kalsaria (2):
  qlcnic: Update Link speed and port type info for 83xx adapter
  qlcnic: Use usleep_range() instead of msleep() for sleep less than
    20ms

Shahed Shaikh (4):
  qlcnic: Add support for 0x8830 device ID
  qlcnic: Add support to run firmware POST
  MAINTAINERS: Update group email alias for qlcnic driver
  qlcnic: Update version to 5.3.62

 MAINTAINERS                                        |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    8 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  221 ++++++++++++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  156 ++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   10 +-
 8 files changed, 337 insertions(+), 70 deletions(-)
