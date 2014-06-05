From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: systemport: misc fixes
Date: Thu,  5 Jun 2014 10:22:14 -0700
Message-ID: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:61952 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbaFERWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:22:38 -0400
Received: by mail-pd0-f179.google.com with SMTP id fp1so1365783pdb.10
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 10:22:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains some misc fixes for the SYSTEMPORT driver.

Thanks!

Florian Fainelli (4):
  net: systemport: fix transmit locking scheme
  net: systemport: correctly check for RX_STATUS_OVFLOW flag
  net: systemport: fix comment about HW prepending 2bytes
  net: systemport: start with carrier off

 drivers/net/ethernet/broadcom/bcmsysport.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

-- 
1.9.1
