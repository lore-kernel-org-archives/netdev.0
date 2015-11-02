From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH net-next 0/6] net: dsa: mv88e6060: cleanup and fix setup
Date: Mon, 2 Nov 2015 11:57:01 +0100
Message-ID: <5637417D.6060503@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces somes fixes and a registers addressing cleanup for
the mv88e6060 DSA driver.

The first patch removes the poll_link as mv88e6xxx.
The 3 following patchs fixes the setup in regards of the datasheet.
The 2 last patches introduces a clean header and replaces all magic values.

Neil Armstrong (6):
  net: dsa: mv88e6060: remove poll_link callback
  net: dsa: mv88e6060: use the correct InitReady bit
  net: dsa: mv88e6060: use the correct MaxFrameSize bit
  net: dsa: mv88e6060: use the correct bit shift for mac0
  net: dsa: mv88e6060: add register defines header file
  net: dsa: mv88e6060: replace magic values with register defines

 drivers/net/dsa/mv88e6060.c | 114 +++++++++++++++-----------------------------
 drivers/net/dsa/mv88e6060.h | 108 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+), 76 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6060.h

-- 
1.9.1
