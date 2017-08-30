From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 0/5] net: mdio-mux: Misc fix
Date: Wed, 30 Aug 2017 19:46:46 +0200
Message-ID: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

This patch series fix minor problems found when working on the
dwmac-sun8i syscon mdio-mux.

Regards

Corentin Labbe (5):
  net: mdio-mux: Fix NULL Comparison style
  net: mdio-mux: Remove unnecessary 'out of memory' message
  net: mdio-mux: printing driver version is useless
  net: mdio-mux-mmioreg: Can handle 8/16/32 bits registers
  net: mdio-mux: fix unbalanced put_device

 drivers/net/phy/Kconfig    |  2 +-
 drivers/net/phy/mdio-mux.c | 15 ++++-----------
 2 files changed, 5 insertions(+), 12 deletions(-)

-- 
2.13.5
