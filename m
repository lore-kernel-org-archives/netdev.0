From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 0/2] net: systemport: couple fixes
Date: Fri,  9 May 2014 13:16:37 -0700
Message-ID: <1399666599-19398-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:58929 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088AbaEIURF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:17:05 -0400
Received: by mail-yk0-f170.google.com with SMTP id 10so3893263ykt.15
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 13:17:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set fixes a few minor issues found in the SYSTEMPORT driver while
doing some more testing with its switching hardware.

Florian Fainelli (2):
  net: systemport: only update UMAC_CMD if something changed
  net: systemport: pad packets to a minimum of 64 bytes

 drivers/net/ethernet/broadcom/bcmsysport.c | 32 +++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

-- 
1.9.1
