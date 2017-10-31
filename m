From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] PHYLINK cosmetic and build fixes
Date: Mon, 30 Oct 2017 21:42:56 -0700
Message-ID: <20171031044258.16094-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, rmk+kernel@armlinux.org.uk, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:56366 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdJaEnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 00:43:03 -0400
Received: by mail-oi0-f68.google.com with SMTP id v9so25406221oif.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 21:43:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Russell,

Please find two small "fixes" one that corrects some stylistic changes and
another one that fixes an actual build failure in sfp.c. Since PHYLINK is
not directly visible to user, and there are no in-tree users yet (coming)
this is not targeted at "net" but "net-next" instead.

Thanks

Florian Fainelli (2):
  net: phy: Cosmetic fixes to phylink/sfp/sfp-bus.c
  net: phy: Fix sfp.c build against GPIO definitions

 drivers/net/phy/phylink.c | 13 ++++++-------
 drivers/net/phy/sfp-bus.c | 11 +++--------
 drivers/net/phy/sfp.c     | 29 ++++++++++++++---------------
 3 files changed, 23 insertions(+), 30 deletions(-)

-- 
2.14.1
