From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] Bring back transceiver type for PHYLIB
Date: Wed, 20 Sep 2017 15:52:12 -0700
Message-ID: <20170920225214.21974-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com, decot@googlers.com,
        tremyfr@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36042 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdITWwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:52:20 -0400
Received: by mail-qk0-f194.google.com with SMTP id i14so2596698qke.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 15:52:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

With the introduction of the xLINKSETTINGS ethtool APIs, the transceiver type
was deprecated, but in that process we lost some useful information that PHYLIB
was consistently reporting about internal vs. external PHYs.

This brings back transceiver as a read-only field that is only consumed in the
legacy path where ETHTOOL_GET is called but the underlying drivers implement the
new style klink_settings API.

Florian Fainelli (2):
  net: ethtool: Add back transceiver type
  net: phy: Keep reporting transceiver type

 drivers/net/phy/phy.c        | 3 ++-
 include/uapi/linux/ethtool.h | 6 +++++-
 net/core/ethtool.c           | 2 ++
 3 files changed, 9 insertions(+), 2 deletions(-)

-- 
2.9.3
