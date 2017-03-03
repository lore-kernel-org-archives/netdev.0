From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 0/7] bnx2x: PTP crash, VF VLAN fixes
Date: Fri,  3 Mar 2017 17:08:27 +0100
Message-ID: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdCCQIm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
here are fixes for a crash with PTP, a crash in setting of VF multicast
addresses, and non-working VLAN filters configuration from the VF side.

Michal Schmidt (7):
  bnx2x: prevent crash when accessing PTP with interface down
  bnx2x: lower verbosity of VF stats debug messages
  bnx2x: fix possible overrun of VFPF multicast addresses array
  bnx2x: fix detection of VLAN filtering feature for VF
  bnx2x: do not rollback VF MAC/VLAN filters we did not configure
  bnx2x: fix incorrect filter count in an error message
  bnx2x: add missing configuration of VF VLAN filters

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 36 ++++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 15 ++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 40 ++++++++++++++++-------
 4 files changed, 70 insertions(+), 22 deletions(-)

-- 
2.9.3
