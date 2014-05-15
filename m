From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: systemport: DMA and MAC fixes
Date: Thu, 15 May 2014 14:33:51 -0700
Message-ID: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:58162 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbaEOVeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:34:24 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar20so1661222iec.35
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 14:34:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains a critical fix in how the DMA unmapping of packet
is done, as well as a less critical fix in how we disable the Ethernet MAC
RX/TX functions.

Thanks!

Florian Fainelli (2):
  net: systemport: fix dma_unmap_single() len
  net: systemport: wait for packet in umac_enable_set()

 drivers/net/ethernet/broadcom/bcmsysport.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

-- 
1.9.1
