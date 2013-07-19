From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 0/9] qlcnic: bug fixes
Date: Fri, 19 Jul 2013 16:56:25 -0400
Message-ID: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:41057
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751813Ab3GSVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply to net.

Thanks,
Sucheta.

Himanshu Madhani (1):
  qlcnic: Fix ethtool display for 83xx adapter.

Jitendra Kalsaria (1):
  qlcnic: Fix releasing of Tx frag which was never mapped.

Manish Chopra (2):
  qlcnic: Fix panic while setting VF's MAC address
  qlcnic: Fix guest VLAN

Pratik Pujar (1):
  qlcnic: Set __QLCNIC_DEV_UP in adapter state before enabling
    interrupts

Shahed Shaikh (2):
  qlcnic: Fix invalid register offset calculation
  qlcnic: Fix dump template version mask

Sucheta Chakraborty (2):
  qlcnic: Fix NULL pointer dereference in VF probe path.
  qlcnic: Fix multicast packet handling for PF and VF.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    3 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   22 +++++++++----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   16 +++++++++++--
 8 files changed, 31 insertions(+), 22 deletions(-)
