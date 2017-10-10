From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 0/2] lan9303: Add basic offloading of unicast traffic
Date: Tue, 10 Oct 2017 14:49:51 +0200
Message-ID: <20171010124953.386-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series add basic offloading of unicast traffic to the lan9303
DSA driver.

Review welcome!
 
Changes v1 -> v2:
 - Patch 1: Codestyle linting.
 - Patch 2: Remember SWE_PORT_STATE while not bridged.
            Added constant LAN9303_SWE_PORT_MIRROR_DISABLED.


Egil Hjelmeland (2):
  net: dsa: lan9303: Move tag setup to new lan9303_setup_tagging
  net: dsa: lan9303: Add basic offloading of unicast traffic

 drivers/net/dsa/lan9303-core.c | 124 +++++++++++++++++++++++++++++++++++------
 drivers/net/dsa/lan9303.h      |   2 +
 2 files changed, 109 insertions(+), 17 deletions(-)

-- 
2.11.0
