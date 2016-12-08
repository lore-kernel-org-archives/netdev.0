From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: ethernet: Make sure we set dev->dev.parent
Date: Thu,  8 Dec 2016 11:41:23 -0800
Message-ID: <20161208194125.13264-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, madalin.bucur@nxp.com, johan@kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35733 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbcLHTl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:41:29 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so13334570pfk.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:41:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series builds atop:

ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461 ("phy: Don't increment MDIO bus
refcount unless it's a different owner")

FMAN is the one that potentially needs patching as well (call SET_NETDEV_DEV),
but there appears to be no way that init_phy is called right now, or there is
not such an in-tree user. Madalin, can you comment on that?

Florian Fainelli (2):
  net: ethernet: lantiq_etop: Call SET_NETDEV_DEV()
  net: ethernet: cpmac: Call SET_NETDEV_DEV()

 drivers/net/ethernet/lantiq_etop.c | 1 +
 drivers/net/ethernet/ti/cpmac.c    | 1 +
 2 files changed, 2 insertions(+)

-- 
2.9.3
