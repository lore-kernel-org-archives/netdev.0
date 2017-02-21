From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/3] bnxt_en: Fix probe and open bugs.
Date: Mon, 20 Feb 2017 19:25:15 -0500
Message-ID: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33601 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751023AbdBUAZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 19:25:35 -0500
Received: by mail-qk0-f171.google.com with SMTP id p22so109445532qka.0
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 16:25:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 3 issues related to bnxt_init_one() and bnxt_open().  Don't probe
bridge devices and fixup some error code paths.

Michael Chan (1):
  bnxt_en: Fix NULL pointer dereference in a failure path during open.

Ray Jui (1):
  bnxt_en: Reject driver probe against all bridge devices

Sathya Perla (1):
  bnxt_en: fix pci cleanup in bnxt_init_one() failure path

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 82 ++++++++++++++++---------------
 1 file changed, 43 insertions(+), 39 deletions(-)

-- 
1.8.3.1
