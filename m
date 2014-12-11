From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: dsa: two small bug fixes
Date: Thu, 11 Dec 2014 12:49:14 -0800
Message-ID: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, computersforpeace@gmail.com,
	andrey.volkov@nexvision.fr, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:55914 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758647AbaLKUte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:49:34 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so5684005pac.8
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 12:49:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are two small fixes for the DSA slave interface creation code:

- first patch fixes a null pointer de-reference with an invalid PHY
  device pointer while calling phy_connect_direct()

- second path propagates the dsa_slave_phy_setup() error code down to
  its caller: dsa_slave_create

Thanks!

Florian Fainelli (2):
  net: dsa: handle non-existing PHYs on switch internal bus
  net: dsa: propagate error code from dsa_slave_phy_setup

 net/dsa/slave.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

-- 
2.1.0
