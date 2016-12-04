From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: ethoc: Misc improvements
Date: Sun,  4 Dec 2016 12:40:27 -0800
Message-ID: <20161204204030.9853-1-f.fainelli@gmail.com>
Cc: tremyfr@gmail.com, tklauser@distanz.ch, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35085 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLDUkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 15:40:36 -0500
Received: by mail-oi0-f67.google.com with SMTP id v84so33924063oie.2
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 12:40:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series fixes/improves a few things:

- implement a proper PHYLIB adjust_link callback to set the duplex mode
  accordingly
- do not open code the fetching of a MAC address in OF/DT environments
- demote an error message that occurs more frequently than expected in low
  CPU/memory/bandwidth environments

Tested on a Cirrus Logic EP93xx / TS7300 board.

Florian Fainelli (3):
  net: ethoc: Account for duplex changes
  net: ethoc: Utilize of_get_mac_address()
  net: ethoc: Demote packet dropped error message to debug

 drivers/net/ethernet/ethoc.c | 44 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 39 insertions(+), 5 deletions(-)

-- 
2.9.3
