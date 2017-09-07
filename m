From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 0/6] Modify KSZ9477 DSA driver in preparation to add
 other KSZ switch drivers.
Date: Thu, 7 Sep 2017 21:08:53 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218B7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411218B7@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

This series of patches is to modify the original KSZ9477 DSA driver so that other KSZ switch drivers can be added and use the common code.

This patch set is against net-next.

 drivers/net/dsa/microchip/Makefile     |    2 +-
 drivers/net/dsa/microchip/ksz9477.c    | 1317 ++++++++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz_common.c | 1156 +---------------------------
 drivers/net/dsa/microchip/ksz_priv.h   |  105 ++-
 drivers/net/dsa/microchip/ksz_spi.c    |   13 +-
 net/dsa/tag_ksz.c                      |   40 +-
 6 files changed, 1458 insertions(+), 1175 deletions(-)  create mode 100644 drivers/net/dsa/microchip/ksz9477.c
