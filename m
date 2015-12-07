From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 net-next 0/4] Further fix for dsa unbinding
Date: Mon,  7 Dec 2015 13:57:31 +0100
Message-ID: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
References: <56321D9A.8010109@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56321D9A.8010109@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This serie fixes further issues for DSA dynamic unbinding.
The first patch completely removes the PHY link state polling.
The two following cleans up the dsa state upon removal.
The last patch moves slave destroy code as slave function and
adds missing netdev and phy cleanup calls.

v1: http://lkml.kernel.org/r/562F8ECB.6050709@baylibre.com
v2: http://lkml.kernel.org/r/56321D9A.8010109@baylibre.com
remove phy fix and add missing calls in dsa_switch_destroy
then add dedicated dsa_slave_destroy

v3: remove polling instead of fixing it, make single patch for
dsa slave destroy

Neil Armstrong (4):
  net: dsa: remove DSA link polling
  net: dsa: cleanup resources upon module removal
  net: dsa: Add missing master netdev dev_put() calls
  net: dsa: move dsa slave destroy code to slave.c

 include/net/dsa.h  | 12 -----------
 net/dsa/dsa.c      | 60 +++++++++++++-----------------------------------------
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 11 ++++++++++
 4 files changed, 26 insertions(+), 58 deletions(-)

-- 
1.9.1
