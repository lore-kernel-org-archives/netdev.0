From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v2 0/4] net: dsa: cleanup dsa driver
Date: Wed, 28 Oct 2015 15:12:44 +0100
Message-ID: <5630D7DC.1020300@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a new remove callback to allow DSA drivers to cleanup their
ressources.
Then add a remove implementation for bcm_sf2 and mv88e6xxx.

This patch was not tested due of a lack of hardware.

v2: add remove callback patch to the serie

Neil Armstrong (4):
  net: dsa: allow switch drivers to cleanup their resources
  net: dsa: bcm_sf2: cleanup resources in remove callback
  net: dsa: mv88e6xxx: add common and ppu remove function
  net: dsa: make usage of mv88e6xxx common remove function

 drivers/net/dsa/bcm_sf2.c         | 20 ++++++++++++++++++++
 drivers/net/dsa/mv88e6123_61_65.c |  1 +
 drivers/net/dsa/mv88e6131.c       |  8 ++++++++
 drivers/net/dsa/mv88e6171.c       |  1 +
 drivers/net/dsa/mv88e6352.c       |  1 +
 drivers/net/dsa/mv88e6xxx.c       | 18 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  2 ++
 include/net/dsa.h                 |  1 +
 net/dsa/dsa.c                     |  4 ++++
 9 files changed, 56 insertions(+)

-- 
1.9.1
