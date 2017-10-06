From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 0/1] Add Microchip KSZ8795 DSA driver
Date: Fri, 6 Oct 2017 13:33:42 -0700
Message-ID: <1507322023-15182-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

This patch requires the previous patches for Microchip KSZ9477 DSA driver.

v1
- Return error codes instead of numbers
- Add more comments to clarify operation
- Use ksz8795 prefix to indicate KSZ8795 specific code
- Simplify MIB counter reading code
- Switch driver code is not accessed from tag_ksz.c

Tristram Ha (1):
  Add Microchip KSZ8795 DSA driver.

 drivers/net/dsa/microchip/Kconfig       |   17 +
 drivers/net/dsa/microchip/Makefile      |    2 +
 drivers/net/dsa/microchip/ksz8795.c     | 1372 +++++++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8795_reg.h | 1016 +++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8795_spi.c |  166 ++++
 drivers/net/dsa/microchip/ksz_priv.h    |    1 +
 include/net/dsa.h                       |    1 +
 net/dsa/Kconfig                         |    4 +
 net/dsa/dsa.c                           |    3 +
 net/dsa/dsa_priv.h                      |    1 +
 net/dsa/tag_ksz.c                       |   37 +
 11 files changed, 2620 insertions(+)
 create mode 100644 drivers/net/dsa/microchip/ksz8795.c
 create mode 100644 drivers/net/dsa/microchip/ksz8795_reg.h
 create mode 100644 drivers/net/dsa/microchip/ksz8795_spi.c

-- 
1.9.1
