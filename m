From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 RESEND 0/6] Calxeda xgmac performance fixes
Date: Thu,  1 Nov 2012 05:40:58 -0500
Message-ID: <1351766464-27354-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64228 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437Ab2KAKlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 06:41:19 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1000955bkc.19
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 03:41:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

This is a repost for 3.8 inclusion. Only patch 5 has changed from v1
and was previously posted.

This is a series of performance improvements to the xgmac driver. The
most significant changes are the alignment fixes to avoid alignment
traps on received frames and using relaxed i/o accessors.

Rob

Rob Herring (6):
  net: calxedaxgmac: enable operate on 2nd frame mode
  net: calxedaxgmac: remove explicit rx dma buffer polling
  net: calxedaxgmac: use relaxed i/o accessors in rx and tx paths
  net: calxedaxgmac: drop some unnecessary register writes
  net: calxedaxgmac: rework transmit ring handling
  net: calxedaxgmac: ip align receive buffers

 drivers/net/ethernet/calxeda/Kconfig |    2 +-
 drivers/net/ethernet/calxeda/xgmac.c |   59 +++++++++++++++-------------------
 2 files changed, 27 insertions(+), 34 deletions(-)

-- 
1.7.10.4
