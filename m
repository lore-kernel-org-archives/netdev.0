From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/2] net: systemport: couple fixes
Date: Mon,  5 May 2014 12:20:50 -0700
Message-ID: <1399317652-20078-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:50429 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbaEETVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:21:13 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so2728978igb.2
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 12:21:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a few minor issues found in the SYSTEMPORT driver while
doing some more testing with its switching hardware.

Florian Fainelli (2):
  net: systemport: only update UMAC_CMD if something changed
  net: systemport: pad packets to a minimum of 64 bytes

 drivers/net/ethernet/broadcom/bcmsysport.c | 34 +++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 10 deletions(-)

-- 
1.9.1
