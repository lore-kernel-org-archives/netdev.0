From: John Crispin <john@phrozen.org>
Subject: [PATCH 0/3] net-next: dsa: add QCA8K support
Date: Mon, 12 Sep 2016 10:35:34 +0200
Message-ID: <1473669337-21221-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:48581 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756592AbcILIgi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 04:36:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

 .../devicetree/bindings/net/dsa/qca8k.txt          |   53 ++
 drivers/net/dsa/Kconfig                            |    9 +
 drivers/net/dsa/Makefile                           |    1 +
 drivers/net/dsa/qca8k.c                            |  969 ++++++++++++++++++++
 drivers/net/dsa/qca8k.h                            |  201 ++++
 include/net/dsa.h                                  |    1 +
 net/dsa/Kconfig                                    |    3 +
 net/dsa/Makefile                                   |    1 +
 net/dsa/dsa.c                                      |    3 +
 net/dsa/dsa_priv.h                                 |    2 +
 net/dsa/tag_qca.c                                  |  158 ++++
 11 files changed, 1401 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/qca8k.txt
 create mode 100644 drivers/net/dsa/qca8k.c
 create mode 100644 drivers/net/dsa/qca8k.h
 create mode 100644 net/dsa/tag_qca.c

-- 
1.7.10.4
