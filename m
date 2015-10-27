From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 0/6] Further fix for dsa unbinding
Date: Tue, 27 Oct 2015 15:48:43 +0100
Message-ID: <562F8ECB.6050709@baylibre.com>
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
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This serie fixes further issues for DSA dynamic unbinding.
Frode Isaksen's patches make usage of delayed work and fixes kernel
crashes when dsa is unbind.
The other patches are simple fixes to permit cleanup and avoid netdev
related crashes.

Frode Isaksen (3):
  net: dsa: Use delayed work instead of timer+work for polling
  net: dsa: Do not reschedule polling if driver removed
  net: phy: Stop 'phy-state-machine' and 'phy_change' work on remove

Neil Armstrong (3):
  net: dsa: allow switch drivers to cleanup their resources
  net: dsa: cleanup resources upon module removal
  net: dsa: Add missing master netdev dev_put() calls

 drivers/net/phy/phy_device.c |  6 ++++++
 include/net/dsa.h            |  4 ++--
 net/dsa/dsa.c                | 46 +++++++++++++++++++++++++-------------------
 3 files changed, 34 insertions(+), 22 deletions(-)

-- 
1.9.1
