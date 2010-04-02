From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/2] Fix ethernet driver for Octeon based Movidis hardware
Date: Thu,  1 Apr 2010 18:17:53 -0700
Message-ID: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Cc: davem@davemloft.net, David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:10722 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756810Ab0DBBSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:18:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Movidis X16 bootloader doesn't enable the mdio bus.  The first
patch fixes this by enabling the mdio bus when the driver is
initialized.

Also the addresses of the PHYs was unknown for this device.  The
second patch adds the corresponding PHY addresses.

With both patches applied I can successfully use all eight Ethernet
ports.

Please consider for 2.6.34.  Since Octeon is an embedded MIPS SOC it
is unlikely to break the kernel for any workstations.  Any or all of
these could be considered for merging via Ralf's linux-mips.org tree.

Thanks,

David Daney (2):
  netdev: phy/mdio-octeon: Enable the hardware before using it.
  staging: octeon-ethernet: Use proper phy addresses for Movidis
    hardware.

 drivers/net/phy/mdio-octeon.c              |   10 ++++++++++
 drivers/staging/octeon/cvmx-helper-board.c |    8 ++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

