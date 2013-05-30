From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/5] netxen_nic: Code cleanup and enhancements
Date: Thu, 30 May 2013 15:51:33 -0400
Message-ID: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0186.outbound.messaging.microsoft.com ([213.199.154.186]:2102
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756648Ab3E3URB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:17:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series includes following changes:

* Log driver version information with firmware version information.
* Log "Unknown" adapter name and serial number in case of
  mismatched adapter type.
* netxen_setup_intr() function code cleanup and changes to avoid attaching
  of multiple pci functions on an adapter with mixed interrupts mode
  [MSI-X/MSI + INTx].

Please apply this series to net-next.

Thanks,
Manish


Manish Chopra (5):
  netxen_nic: Log driver version with firmware version
  netxen_nic: Log proper error message in case of mismatched adapter type
  netxen_nic: netxen_setup_intr() function code cleanup
  netxen_nic: Avoid mixed mode interrupts
  netxen_nic: Update version to 4.0.81

 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   14 ++-
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |    3 +
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  127 ++++++++++++++------
 3 files changed, 102 insertions(+), 42 deletions(-)
