From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool 0/2] Adding PHY Loopback tunable
Date: Mon, 28 Nov 2016 14:25:10 +0100
Message-ID: <1480339512-5882-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linville@tuxdriver.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0057.outbound.protection.outlook.com ([104.47.41.57]:43568
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932464AbcK1NZe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch implements for support for PHY Loopback using PHY-Tunables.

The patch will add the following options:

    ethtool --set-phy-tunable DEVNAME      Set PHY tunable
                [ loopback off|near|far|extn ]
    ethtool --get-phy-tunable DEVNAME      Get PHY tunable
                [ loopback ]

Please review.

Best regards
Allan and Raju

Raju Lakkaraju (2):
  ethtool-copy.h:sync with net
  Ethtool: Implements PHY Loopback

 ethtool-copy.h |  23 +++++++++-
 ethtool.8.in   |  49 ++++++++++++++++++++
 ethtool.c      | 139 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 210 insertions(+), 1 deletion(-)

-- 
2.7.3
