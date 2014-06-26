From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/3] net: systemport: misc fixes
Date: Thu, 26 Jun 2014 10:06:43 -0700
Message-ID: <1403802406-10992-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:64503 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757348AbaFZRHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:07:25 -0400
Received: by mail-pa0-f47.google.com with SMTP id kq14so3416776pab.6
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:07:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains 3 small fixes for the SYSTEM PORT driver

Thanks!

Florian Fainelli (3):
  net: systemport: do not clear IFF_MULTICAST flag
  net: systemport: fix UniMAC reset logic
  net: systemport: fix TX NAPI work done return value

 drivers/net/ethernet/broadcom/bcmsysport.c | 43 ++++++++----------------------
 1 file changed, 11 insertions(+), 32 deletions(-)

-- 
1.9.1
