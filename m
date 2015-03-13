From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/2] net: bcmgenet: xmit_more support
Date: Fri, 13 Mar 2015 12:11:05 -0700
Message-ID: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39025 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbCMTLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:11:49 -0400
Received: by pdbft15 with SMTP id ft15so30958073pdb.6
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 12:11:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds xmit_more support to the GENET driver by allowing
the deferal of the producer index write to the TDMA engine.

Changes in v2:

- move the netif_tx_stop_queue check *before* updating the producer index

Florian Fainelli (2):
  net: bcmgenet: update ring producer index and buffer count in xmit
  net: bcmgenet: add support for xmit_more

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

-- 
2.1.0
