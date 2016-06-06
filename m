From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Bug fixes.
Date: Mon,  6 Jun 2016 02:37:13 -0400
Message-ID: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33762 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcFFGh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 02:37:26 -0400
Received: by mail-pa0-f48.google.com with SMTP id ec8so26683041pac.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 23:37:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a race condition and VLAN rx acceleration logic.

Michael Chan (3):
  bnxt_en: Fix tx push race condition.
  bnxt_en: Enable and disable RX CTAG and RX STAG VLAN acceleration
    together.
  bnxt_en: Simplify VLAN receive logic.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 47 +++++++++++++++++--------------
 1 file changed, 26 insertions(+), 21 deletions(-)

-- 
1.8.3.1
