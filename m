From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: bcmgenet: Byte Queue Limits support
Date: Fri, 13 Mar 2015 15:58:30 -0700
Message-ID: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36004 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243AbbCMW7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:59:40 -0400
Received: by padcy3 with SMTP id cy3so1177677pad.3
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:59:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This path series adds byte queue limits support to the GENET driver. Just like
the gianfar driver, we sometimes need to insert a 64 bytes transmit status block
which is not going to be sent on the wire, just to the TDMA/TBUF, so we need to
record the correct byte count before doing that SKB inflation.

Florian Fainelli (2):
  net: bcmgenet: use skb_put_padto()
  net: bcmgenet: add byte queue limits support

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 23 ++++++++++++++++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++++++
 2 files changed, 24 insertions(+), 5 deletions(-)

-- 
2.1.0
