From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 0/5] be2net: patch set
Date: Wed, 22 Jun 2016 08:54:52 -0400
Message-ID: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:62538 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751745AbcFVMzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, pls consider commiting the following patches to the net-next tree.
Thanks!

Patch 1 replaces the be_max_eqs() macro with two new macros called
be_max_nic_eqs() and be_max_func_eqs() to clear confusion in that part
of the code.

Patch 2 adds support to configure asymmetric number of rx/tx queues via
ethtool set-channels option.

Patch 3 disables EVB when VFs are not enabled on a BE3 SR-IOV config to
avoid the broadcast echo problem.

Patch 4 updates copyright markings in be2net src files

Patch 5 updates the be2net maintainers' list

Sathya Perla (3):
  be2net: fix definition of be_max_eqs()
  be2net: support asymmetric rx/tx queue counts
  be2net: update be2net maintainers list

Somnath Kotur (2):
  be2net: Fix broadcast echoes from EVB in BE3
  be2net: Change copyright markings in source files

 MAINTAINERS                                    |  3 +-
 drivers/net/ethernet/emulex/benet/be.h         | 36 +++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 13 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 31 +++++++--
 drivers/net/ethernet/emulex/benet/be_main.c    | 89 +++++++++++++++++---------
 drivers/net/ethernet/emulex/benet/be_roce.c    |  2 +-
 drivers/net/ethernet/emulex/benet/be_roce.h    |  2 +-
 8 files changed, 128 insertions(+), 50 deletions(-)

-- 
2.4.1
