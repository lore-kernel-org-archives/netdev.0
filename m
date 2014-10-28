From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: systemport: RX path and suspend fixes
Date: Tue, 28 Oct 2014 11:11:59 -0700
Message-ID: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:41193 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaJ1SMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 14:12:31 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so1210721pdj.28
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 11:12:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches fix a race condition where we have our RX interrupts
enabled, but not NAPI for the RX path, and the second patch fixes an
issue for packets stuck in RX fifo during a suspend/resume cycle.

Thanks!

Florian Fainelli (2):
  net: systemport: enable RX interrupts after NAPI
  net: systemport: reset UniMAC coming out of a suspend cycle

 drivers/net/ethernet/broadcom/bcmsysport.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

-- 
1.9.1
