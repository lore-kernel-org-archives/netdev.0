From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/2] bnxt_en: Error handling and netpoll fixes.
Date: Fri, 23 Jun 2017 14:00:59 -0400
Message-ID: <1498240861-17730-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:32836 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754014AbdFWSBP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:01:15 -0400
Received: by mail-qk0-f175.google.com with SMTP id r62so41549799qkf.0
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 11:01:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing error handling and fix netpoll handling.  The current code
handles RX and TX events in netpoll mode and is causing lots of warnings
and errors in the RX code path in netpoll mode.  The fix is to only handle
TX events in netpoll mode.

Michael Chan (2):
  bnxt_en: Add missing logic to handle TPA end error conditions.
  bnxt_en: Fix netpoll handling.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 61 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  6 ++-
 2 files changed, 57 insertions(+), 10 deletions(-)

-- 
1.8.3.1
