From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/6] bnxt_en: Add support for NS2 Nitro.
Date: Mon, 18 Jul 2016 07:15:19 -0400
Message-ID: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34331 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcGRLPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:35 -0400
Received: by mail-oi0-f52.google.com with SMTP id l65so161126246oib.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for the embedded version of the
ethernet controller (Nitro) in the North Star 2 SoC.  There are a number
of features not supported and a software workaround for a hardware rx
bug is required for Nitro A0.  Please review.

Prashant Sreedharan (6):
  bnxt_en: Add basic support for Nitro in North Star 2.
  bnxt_en: Workaround Nitro A0 hardware RX bug (part 1).
  bnxt_en: Workaround Nitro A0 hardware RX bug (part 2).
  bnxt_en: Workaround Nitro A0 hardware RX bug (part 3).
  bnxt_en: Workaround Nitro A0 RX hardware bug (part 4).
  bnxt_en: Add BCM58700 PCI device ID for NS2 Nitro.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 254 ++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   6 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  12 +-
 3 files changed, 229 insertions(+), 43 deletions(-)

-- 
1.8.3.1
