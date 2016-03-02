From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 0/7] bnx2x: endianness fixes
Date: Wed,  2 Mar 2016 13:47:04 +0100
Message-ID: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcCBMoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
this fixes a VLAN crash and some SRIOV bugs in bnx2x observed on ppc64.

Michal Schmidt (7):
  bnx2x: fix crash on big-endian when adding VLAN
  bnx2x: fix sending VF->PF messages on big-endian
  bnx2x: fix receive of VF->PF mailbox messages by the PF on big-endian
  bnx2x: access cfc_del_event only if the opcode is CFC_DEL
  bnx2x: define fields of struct cfc_del_event_data as little-endian
  bnx2x: define event data reserved fields as little-endian
  bnx2x: fix indentation in bnx2x_sp_task()

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h   | 36 ++++++++++-------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 22 +++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 12 ++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |  4 +--
 4 files changed, 32 insertions(+), 42 deletions(-)

-- 
2.5.0
