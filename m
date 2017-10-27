From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/7] net: dsa: add port parsing functions
Date: Fri, 27 Oct 2017 15:55:12 -0400
Message-ID: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds port parsing functions called early in the new
bindings parsing stage, which regroup all the fetching of static data
available at the port level, including the port's type, name and CPU
master interface.

This simplifies the rest of the code which does not need to dig into
device tree or platform data again in order to check a port's type or
name.

Vivien Didelot (7):
  net: dsa: get ports within parsing code
  net: dsa: add port parse functions
  net: dsa: get port type at parse time
  net: dsa: check master device before put
  net: dsa: get master device at port parsing time
  net: dsa: get port name at parse time
  net: dsa: remove name arg from slave create

 net/dsa/dsa2.c     | 163 +++++++++++++++++++++++++++++------------------------
 net/dsa/dsa_priv.h |   2 +-
 net/dsa/legacy.c   |   3 +-
 net/dsa/slave.c    |   3 +-
 4 files changed, 95 insertions(+), 76 deletions(-)

-- 
2.14.3
