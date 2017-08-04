From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: remove unnecessary arguments
Date: Fri,  4 Aug 2017 18:23:17 -0400
Message-ID: <20170804222320.10986-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several DSA core functions take many arguments, mostly because the
legacy code does not assign ds->dev. This patch series assigns ds->dev
in legacy and removes the unnecessary arguments of these functions,
where either the dsa_switch or dsa_port argument is enough.

Vivien Didelot (3):
  net: dsa: assign switch device in legacy code
  net: dsa: remove useless args of dsa_cpu_dsa_setup
  net: dsa: remove useless args of dsa_slave_create

 net/dsa/dsa.c      | 10 +++++-----
 net/dsa/dsa2.c     |  6 +++---
 net/dsa/dsa_priv.h |  6 ++----
 net/dsa/legacy.c   | 19 +++++++++----------
 net/dsa/slave.c    | 14 +++++++-------
 5 files changed, 26 insertions(+), 29 deletions(-)

-- 
2.13.3
