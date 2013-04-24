From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 0/7] qlcnic: Driver updates
Date: Wed, 24 Apr 2013 18:42:38 -0400
Message-ID: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:15248
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757971Ab3DXXGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:06:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

This set of patches has following updates:
* Enhanced channel configuration logs by adding logs for various cases.
* Take EPORT out of reset before disabling pause frame generation in the
  adapter.
* Add eSwitch statistics support in ethtool stats.
* Enable interrupt coalescing for 83xx adapter.
* Rename IRQ description.
* Added PCI_VENDOR_ID_QLOGIC, PCI_DEVICE_ID_QLOGIC_834X and PCI_DEVICE_ID_QLOGIC_824X
  for the patch "qlcnic: Add identifying string for 83xx adapter" as per Francois comment.  

Please apply to net-next.

Thanks,
    Jiten

Himanshu Madhani (3):
  qlcnic: Enable Interrupt Coalescing for 83xx adapter
  qlcnic: Rename the IRQ description.
  qlcnic: Add identifying string for 83xx adapter

Manish Chopra (2):
  qlcnic: Enhance channel configuration logs
  qlcnic: Take EPORT out of reset sequence before disabling PAUSE

Shahed Shaikh (2):
  qlcnic: Add eSwitch statistics support
  qlcnic: Update version to 5.2.42

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   22 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   19 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   25 +++
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   77 +++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  193 ++++++++++++++++----
 6 files changed, 277 insertions(+), 61 deletions(-)
