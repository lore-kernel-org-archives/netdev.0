From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 0/8] be2net patch-set
Date: Tue,  2 Feb 2016 15:50:27 +0530
Message-ID: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754583AbcBBKjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patch set contains a few non-critical bug fixes. Please
consider applying this to the net-next tree. Thanks.

Patch-1 fixes be_set_phys_id() ethtool function to return an error code.
Patch-2 fixes a warning when some commands fail for VFs.
Patch-3 fixes be_vlan_rem_vid() to verify vlan being removed is in the list.
Patch-4 improves SRIOV queue distribution logic.
Patch-5 avoids running self test on VFs.
Patch-6 fixes error recovery in Lancer to clean up after moving to ready state.
Patch-7 adds retry logic to error recovery in case of recovery failures
Patch-8 fixes time interval used in eq delay computation routine

********

Padmanabh Ratnakar (3):
  benet: Fix Lancer error recovery
  benet: Add retry in case of error recovery failure
  benet: Fix interval calculation in interrupt moderation

Somnath Kotur (1):
  be2net: Don't run ethtool self-tests for VFs

Sriharsha Basavapatna (2):
  be2net: Fix be_vlan_rem_vid() to check vlan id being removed
  be2net: SRIOV Queue distribution should factor in EQ-count of VFs

Suresh Reddy (2):
  be2net: return error status from be_set_phys_id()
  be2net: check for INSUFFICIENT_PRIVILEGES error

 drivers/net/ethernet/emulex/benet/be.h         |  9 +++
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 32 ++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  3 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 23 ++++---
 drivers/net/ethernet/emulex/benet/be_main.c    | 93 +++++++++++++++++---------
 5 files changed, 114 insertions(+), 46 deletions(-)

-- 
2.3.0.rc2
