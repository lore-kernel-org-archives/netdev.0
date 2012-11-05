From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 0/6] Calxeda xgmac performance fixes
Date: Mon,  5 Nov 2012 10:22:18 -0600
Message-ID: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33164 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab2KEQWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:22:38 -0500
Received: by mail-ob0-f174.google.com with SMTP id uo13so5859114obb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:22:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

This is a series of performance improvements to the xgmac driver. The
most significant changes are the alignment fixes to avoid alignment
traps on received frames and using raw i/o accessors.

v3:
- Only patch 3 changed. Use raw i/o accessors instead of relaxed for
better build coverage.

v2:
- Only patch 5 changed. Add a missing enabling of tx irq.

Rob

Rob Herring (6):
  net: calxedaxgmac: enable operate on 2nd frame mode
  net: calxedaxgmac: remove explicit rx dma buffer polling
  net: calxedaxgmac: use raw i/o accessors in rx and tx paths
  net: calxedaxgmac: drop some unnecessary register writes
  net: calxedaxgmac: rework transmit ring handling
  net: calxedaxgmac: ip align receive buffers

 drivers/net/ethernet/calxeda/xgmac.c |   59 +++++++++++++++-------------------
 1 file changed, 26 insertions(+), 33 deletions(-)

-- 
1.7.10.4
