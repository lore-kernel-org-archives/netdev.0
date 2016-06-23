From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: bgmac: Random fixes
Date: Thu, 23 Jun 2016 14:23:11 -0700
Message-ID: <1466716994-28037-1-git-send-email-f.fainelli@gmail.com>
Cc: nbd@nbd.name, zajec5@gmail.com, davem@davemloft.net,
	hauke@hauke-m.de, jon.mason@broadcom.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35271 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbcFWVXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:23:22 -0400
Received: by mail-pa0-f67.google.com with SMTP id hf6so7313462pac.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 14:23:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series fixes a few issues spotted by code inspection and
actual testing.

Thanks

Florian Fainelli (3):
  net: bgmac: Fix SOF bit checking
  net: bgmac: Start transmit queue in bgmac_open
  net: bgmac: Remove superflous netif_carrier_on()

 drivers/net/ethernet/broadcom/bgmac.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

-- 
2.7.4
