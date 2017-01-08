From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: dsa: bcm_sf2: Couple fixes
Date: Sat,  7 Jan 2017 21:01:55 -0800
Message-ID: <20170108050157.16302-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35972 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753628AbdAHFCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 00:02:00 -0500
Received: by mail-pf0-f196.google.com with SMTP id b22so5882132pfd.3
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 21:02:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are a couple of fixes for bcm_sf2, please queue these up for -stable
as well, thank you very much!

Florian Fainelli (2):
  net: dsa: bcm_sf2: Do not clobber b53_switch_ops
  net: dsa: bcm_sf2: Utilize nested MDIO read/write

 drivers/net/dsa/bcm_sf2.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

-- 
2.9.3
