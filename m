From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/8] qlcnic: Bug fixes
Date: Fri, 2 Aug 2013 23:15:53 -0400
Message-ID: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:19104 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755176Ab3HCD4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 23:56:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series contains the following bug fixes :

* Fix programming of MAC address filter.
* Fix MAC address learning of ingress packets.
* Free memory in error path.
* Remove adapter series name from warning messages.
* Fix external loopback diagnostic test.
* Fix improper link speed display.
* Fix flash update failure due to improper error handling of
  read register API.

Please apply this series to net.

Thanks,
Shahed

Himanshu Madhani (2):
  qlcnic: Free up memory in error path.
  qlcnic: Fix for flash update failure on 83xx adapter

Pratik Pujar (1):
  qlcnic: Removed adapter series name from warning messages.

Rajesh Borundia (2):
  qlcnic: Fix link speed display for 82xx adapter
  qlcnic: Fix link speed and duplex display for 83xx adapter

Shahed Shaikh (3):
  qlcnic: Fix MAC address filter issue on 82xx adapter
  qlcnic: Fix ingress MAC learning
  qlcnic: Fix external loopback test.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   12 +--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  126 ++++++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   91 ++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   16 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   83 ++++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   40 ++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   25 +++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  101 +++++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   19 ++--
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    2 +-
 12 files changed, 335 insertions(+), 184 deletions(-)
