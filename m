From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: restore HWMON support in dsa2
Date: Tue,  3 Jan 2017 13:15:35 -0500
Message-ID: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current HWMON support in DSA in embedded in the legacy code.
Extract it to its own file and register it in the newer DSA code.

Tested on ZII Rev B boards.

Vivien Didelot (3):
  net: dsa: remove out label in dsa_switch_setup_one
  net: dsa: move HWMON support to its own file
  net: dsa: restore HWMON support in dsa2

 net/dsa/Makefile   |   1 +
 net/dsa/dsa.c      | 171 +++++------------------------------------------------
 net/dsa/dsa2.c     |   4 ++
 net/dsa/dsa_priv.h |   9 +++
 net/dsa/hwmon.c    | 149 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 178 insertions(+), 156 deletions(-)
 create mode 100644 net/dsa/hwmon.c

-- 
2.11.0
