From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: systemport: misc fixes
Date: Fri, 20 Jun 2014 13:01:38 -0700
Message-ID: <1403294500-31905-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:56739 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbaFTUBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 16:01:46 -0400
Received: by mail-ig0-f182.google.com with SMTP id l13so912325iga.3
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 13:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are two small fixes for SYSTEMPORT targeted at the 'net' tree, thanks!

Florian Fainelli (2):
  net: systemport: do not clear IFF_MULTICAST flag
  net: systemport: fix UniMAC reset logic

 drivers/net/ethernet/broadcom/bcmsysport.c | 39 +++++++-----------------------
 1 file changed, 9 insertions(+), 30 deletions(-)

-- 
1.9.1
