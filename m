From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: bcmgenet: interrupt coalescing support
Date: Mon, 21 Apr 2014 08:45:20 -0700
Message-ID: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:58388 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbaDUPqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 11:46:07 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so3808744pdi.33
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 08:46:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series adds RX and TX interrupt coalescing support to the BCMGENET
driver. Thanks!

Florian Fainelli (4):
  net: bcmgenet: prepare for MBDONE interrupts support
  net: bcmgenet: add support for ethtool tx-frames
  net: bcmgenet: add support for ethtool rx-frames
  net: bcmgenet: do not set RX buffer length

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 98 +++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  3 +
 3 files changed, 85 insertions(+), 17 deletions(-)

-- 
1.9.1
