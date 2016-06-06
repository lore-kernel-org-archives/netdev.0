From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 0/3] be2net: patch set
Date: Mon,  6 Jun 2016 07:22:07 -0400
Message-ID: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:15324 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751616AbcFFLkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 07:40:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, the following patch set contains three non-critical fixes that
can go into the net-next tree.

Patch 1 fixes the logic for provisioning queue pairs on VFs to take into
account the limit on number of TXQs too as in some profiles the number
of TXQs is less than that of RXQs.

Patch 2 enables WoL support from shutdown on Skyhawk.

Patch 3 enhances the logic for provisioning queue pairs on VFs on
SR-IOV over multi-partition configs. Each PF (partition) on a port has to
compute the number of RSS tables it's VFs can use.

thanks!

Somnath Kotur (1):
  be2net: Fix provisioning of RSS for VFs in multi-partition
    configurations

Sriharsha Basavapatna (1):
  be2net: Enable Wake-On-LAN from shutdown for Skyhawk

Suresh Reddy (1):
  be2net: use max-TXQs limit too while provisioning VF queue pairs

 drivers/net/ethernet/emulex/benet/be.h         |  16 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 147 +++++++++---------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  14 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  35 ++++-
 drivers/net/ethernet/emulex/benet/be_main.c    | 203 +++++++++++++++----------
 5 files changed, 256 insertions(+), 159 deletions(-)

-- 
2.4.1
