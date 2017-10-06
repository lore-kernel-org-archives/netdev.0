From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 0/1] Add Microchip KSZ8895 DSA driver
Date: Fri, 6 Oct 2017 13:33:52 -0700
Message-ID: <1507322033-15222-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

This patch requires the previous patch for Microchip KSZ8795 DSA driver.

Tristram Ha (1):
  Add Microchip KSZ8895 DSA driver.

 drivers/net/dsa/microchip/Kconfig       |   17 +
 drivers/net/dsa/microchip/Makefile      |    2 +
 drivers/net/dsa/microchip/ksz8895.c     | 1288 +++++++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8895_reg.h |  824 ++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8895_spi.c |  157 ++++
 drivers/net/dsa/microchip/ksz_priv.h    |    1 +
 6 files changed, 2289 insertions(+)
 create mode 100644 drivers/net/dsa/microchip/ksz8895.c
 create mode 100644 drivers/net/dsa/microchip/ksz8895_reg.h
 create mode 100644 drivers/net/dsa/microchip/ksz8895_spi.c

-- 
1.9.1
