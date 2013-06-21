From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 0/8] qlcnic: Driver updates
Date: Fri, 21 Jun 2013 12:30:53 -0400
Message-ID: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:20587
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423203Ab3FUQ5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 12:57:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Please apply to net-next.

Thanks,
    Jiten

Jitendra Kalsaria (3):
  qlcnic: Secondary unicast address support.
  qlcnic: Minimize sleep duration within loopback diagnostic test.
  qlcnic: Update version to 5.2.44

Pratik Pujar (2):
  qlcnic: Cleanup of structure qlcnic_hardware_context
  qlcnic: Add support for 'set driver version' in 83XX

Rajesh Borundia (1):
  qlcnic: Add support for 83xx suspend and resume.

Shahed Shaikh (2):
  qlcnic: Handle qlcnic_alloc_mbx_args() failure
  qlcnic: Add support for PEX DMA method to read memory section of
    adapter dump

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   36 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  269 ++++++++++++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   12 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   24 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |   23 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  129 +++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   88 ++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    7 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  138 +++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  225 ++++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   53 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |    2 +-
 15 files changed, 816 insertions(+), 199 deletions(-)
