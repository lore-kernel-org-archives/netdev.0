From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/2] net: systemport: couple fixes
Date: Wed,  7 May 2014 14:36:02 -0700
Message-ID: <1399498564-22037-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34987 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaEGVg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:36:29 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so1525922pdj.6
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 14:36:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes a few minor issues found in the SYSTEMPORT driver while
doing some more testing with its switching hardware.

Florian Fainelli (2):
  net: systemport: only update UMAC_CMD if something changed
  net: systemport: pad packets to a minimum of 64 bytes

 drivers/net/ethernet/broadcom/bcmsysport.c | 36 +++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 11 deletions(-)

-- 
1.9.1
