From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: systemport: misc improvements
Date: Thu, 28 May 2015 15:24:41 -0700
Message-ID: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36502 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbbE1WZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 18:25:24 -0400
Received: by pdfh10 with SMTP id h10so51258560pdf.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 15:25:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These patches are highly inspired by changes from Petri on bcmgenet, last patch
is a misc fix that I had pending for a while, but is not a candidate for 'net'
at this point.

Thanks!

Florian Fainelli (3):
  net: systemport: Pre-calculate and utilize cb->bd_addr
  net: systemport: rewrite bcm_sysport_rx_refill
  net: systemport: Add a check for oversized packets

 drivers/net/ethernet/broadcom/bcmsysport.c | 107 ++++++++++++++++-------------
 drivers/net/ethernet/broadcom/bcmsysport.h |   2 -
 2 files changed, 58 insertions(+), 51 deletions(-)

-- 
2.1.0
