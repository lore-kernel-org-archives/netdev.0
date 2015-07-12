From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: dsa: OF parsing fixes
Date: Sat, 11 Jul 2015 18:02:09 -0700
Message-ID: <1436662931-8982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	dan.carpenter@oracle.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35058 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbGLBCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 21:02:17 -0400
Received: by oihq81 with SMTP id q81so19982748oih.2
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 18:02:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series fixes two small parsing issues, the first one was reported by
Dan, the second came after looking more closely at the code.

Thanks!

Florian Fainelli (2):
  net: dsa: Test array index before use
  net: dsa: Fix off-by-one in switch address parsing

 net/dsa/dsa.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
2.1.4
