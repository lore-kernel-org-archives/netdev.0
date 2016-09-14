From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 0/3] net-next: dsa: add QCA8K support
Date: Wed, 14 Sep 2016 12:38:59 +0200
Message-ID: <1473849542-3298-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is based on the AR8xxx series posted by Matthieu Olivari in may
2015. The following changes were made since then

* fixed the nitpicks from the previous review
* updated to latest API
* turned it into an mdio device
* added callbacks for fdb, bridge offloading, stp, eee, port status
* fixed several minor issues to the port setup and arp learning
* changed the namespacing as this driver to qca8k

The driver has so far only been tested on qca8337/N. It should work on other QCA
switches such as the qca8327 with minor changes.

John Crispin (3):
  Documentation: devicetree: add qca8k binding
  net-next: dsa: add Qualcomm tag RX/TX handler
  net-next: dsa: add new driver for qca8xxx family

 .../devicetree/bindings/net/dsa/qca8k.txt          |   88 ++
 drivers/net/dsa/Kconfig                            |    9 +
 drivers/net/dsa/Makefile                           |    1 +
 drivers/net/dsa/qca8k.c                            |  968 ++++++++++++++++++++
 drivers/net/dsa/qca8k.h                            |  180 ++++
 include/net/dsa.h                                  |    1 +
 net/dsa/Kconfig                                    |    3 +
 net/dsa/Makefile                                   |    1 +
 net/dsa/dsa.c                                      |    3 +
 net/dsa/dsa_priv.h                                 |    2 +
 net/dsa/tag_qca.c                                  |  138 +++
 11 files changed, 1394 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/qca8k.txt
 create mode 100644 drivers/net/dsa/qca8k.c
 create mode 100644 drivers/net/dsa/qca8k.h
 create mode 100644 net/dsa/tag_qca.c

-- 
1.7.10.4
