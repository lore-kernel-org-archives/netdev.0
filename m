From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Small misc. fixes.
Date: Tue, 28 Mar 2017 19:47:28 -0400
Message-ID: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:32768 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbdC1XsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:48:03 -0400
Received: by mail-wr0-f172.google.com with SMTP id w43so77630wrb.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:48:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a NULL pointer crash in open failure path, wrong arguments when
printing error messages, and a DMA unmap bug in XDP shutdown path.

Michael Chan (1):
  bnxt_en: Fix DMA unmapping of the RX buffers in XDP mode during
    shutdown.

Sankar Patchineelam (2):
  bnxt_en: Fix NULL pointer dereference in reopen failure path
  bnxt_en: Correct the order of arguments to netdev_err() in
    bnxt_set_tpa()

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

-- 
1.8.3.1
