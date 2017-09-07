From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 0/5] Add DSA driver support for KSZ8795 switch
Date: Thu, 7 Sep 2017 21:16:56 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A72@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

This series of patches is to add DSA driver support for KSZ8795 switch.

Previous patches for KSZ9477 have to be applied first before these.

This patch set is against net-next.

 drivers/net/dsa/microchip/Kconfig       |   18 +
 drivers/net/dsa/microchip/Makefile      |    2 +
 drivers/net/dsa/microchip/ksz8795.c     | 2066 +++++++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8795.h     | 1015 +++++++++++++++
 drivers/net/dsa/microchip/ksz8795_spi.c |  229 ++++
 5 files changed, 3330 insertions(+)
 create mode 100644 drivers/net/dsa/microchip/ksz8795.c
 create mode 100644 drivers/net/dsa/microchip/ksz8795.h
 create mode 100644 drivers/net/dsa/microchip/ksz8795_spi.c
