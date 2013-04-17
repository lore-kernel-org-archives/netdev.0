From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next v2 0/7] Bug fixes and enhancements
Date: Wed, 17 Apr 2013 13:05:52 -0400
Message-ID: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1351 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S935915Ab3DQR3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 13:29:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Changes in v2:
* Removed check '(netdev->features & (NETIF_F_TSO | NETIF_F_TSO6))'
  from tx fast path in patch "qlcnic: fix TSO race condition" 
  as per Eric's comment.
* Used a local variable for adapter->netdev in
  "qlcnic: Fix typo in logs" and "qlcnic: Enhanced channel configuration logs"
* Reworked "qlcnic: Enable Interrupt Coalescing for 83xx adapter" as per Francois's
  comments.
* Dropped "qlcnic: Add identifying string for 83xx adapter" and
  "qlcnic: Implement GET_LED_STATUS command for 82xx adapter" for further rework.
* Considered "qlcnic: fix beaconing test for 82xx adapter" for 'net'
* Included new patches: "qlcnic: Stop traffic before performing loopback test" and
  "qlcnic: Fix endian data type."

Thanks to Francois and Eric for review comments.

Please apply to net-next.

Thanks,
Shahed

Himanshu Madhani (1):
  qlcnic: Enable Interrupt Coalescing for 83xx adapter

Jitendra Kalsaria (1):
  qlcnic: Stop traffic before performing loopback test

Manish Chopra (1):
  qlcnic: Enhanced channel configuration logs

Rajesh Borundia (1):
  qlcnic: Fix endian data type.

Shahed Shaikh (2):
  qlcnic: Fix typo in logs
  qlcnic: Update version to 5.2.41

Sritej Velaga (1):
  qlcnic: fix TSO race condition

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   32 ++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   37 +++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   70 ++++++++++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   23 +++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   48 +++++++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    4 +-
 9 files changed, 156 insertions(+), 70 deletions(-)
