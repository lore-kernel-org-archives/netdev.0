From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 0/2] lan9303: Add basic offloading of unicast traffic
Date: Thu, 21 Sep 2017 11:41:37 +0200
Message-ID: <20170921094139.4250-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series add basic offloading of unicast traffic to the lan9303
DSA driver.

Comments welcome!

Egil Hjelmeland (2):
  net: dsa: lan9303: Move tag setup to new lan9303_setup_tagging
  net: dsa: lan9303: Add basic offloading of unicast traffic

 drivers/net/dsa/lan9303-core.c | 130 +++++++++++++++++++++++++++++++++++------
 drivers/net/dsa/lan9303.h      |   1 +
 2 files changed, 114 insertions(+), 17 deletions(-)

-- 
2.11.0
