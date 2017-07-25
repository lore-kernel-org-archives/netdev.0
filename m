From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/3] bnxt_en: Fix kbuild errors and rename phys_port_name.
Date: Tue, 25 Jul 2017 13:28:38 -0400
Message-ID: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:37494 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdGYR2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:28:54 -0400
Received: by mail-qk0-f182.google.com with SMTP id q130so32023824qka.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 10:28:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 2 more kbuild errors (the first one already fixed by DaveM), and rename
the physical port name.

Sathya Perla (3):
  bnxt_en: include bnxt_vfr.c code under CONFIG_BNXT_SRIOV switch
  bnxt_en: use SWITCHDEV_SET_OPS() for setting vf_rep_switchdev_ops
  bnxt_en: fix switchdev port naming for external-port-rep and vf-reps

 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |  6 +-----
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 10 +++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h | 30 +++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 7 deletions(-)

-- 
1.8.3.1
