From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/2] net: dsa: make "label" property optional
Date: Fri,  6 Jan 2017 17:00:41 -0500
Message-ID: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48176 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939857AbdAFWBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 17:01:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1/2 makes the "label" property in new DSA bindings optional. This
doesn't change the current behavior with existing DTS files.

As Linux considers the Ethernet switch ports as normal NICs by default,
not providing a "label" property for user ports results in using the
standard "ethX" network device name. Giving a "label" overwrites this.

Patch 2/2 removes the labels for the ZII Rev B board as an example.

Vivien Didelot (2):
  net: dsa: make "label" property optional for dsa2
  arm: dts: vf610-zii-dev-rev-b: remove ports label

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 20 ++++++++-----------
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts         | 16 ---------------
 net/dsa/dsa2.c                                    | 24 ++++-------------------
 3 files changed, 12 insertions(+), 48 deletions(-)

-- 
2.11.0
