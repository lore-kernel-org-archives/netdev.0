From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next v2 00/10] net: dsa: lan9303: unicast offload, fdb,mdb,STP
Date: Tue, 25 Jul 2017 18:15:43 +0200
Message-ID: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: corbet@lwn.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series extends the LAN9303 3 port switch DSA driver. Highlights:
 - Make the MDIO interface work
 - Bridging: Unicast offload
 - Bridging: Added fdb/mdb handling
 - Bridging: STP support
 - Documentation


Changes v1 -> v2:
- sorted out emailing issues, threading and date. And sent from private
  account in order to avoid company disclaimer in emails.
- Removed the three last "work around" patches. But first moved one doc 
  paragraph to the document patch.  

Egil Hjelmeland (10):
  net: dsa: lan9303: Fixed MDIO interface
  net: dsa: lan9303: Do not disable/enable switch fabric port 0 at
    startup
  net: dsa: lan9303: Refactor lan9303_enable_packet_processing()
  net: dsa: lan9303: Added adjust_link() method
  net: dsa: added dsa_net_device_to_dsa_port()
  net: dsa: lan9303: added sysfs node swe_bcst_throt
  net: dsa: lan9303: Added basic offloading of unicast traffic
  net: dsa: lan9303: Added ALR/fdb/mdb handling
  net: dsa: lan9303: Added Documentation/networking/dsa/lan9303.txt
  net: dsa: lan9303: Only allocate 3 ports

 Documentation/networking/dsa/lan9303.txt |  63 +++
 drivers/net/dsa/lan9303-core.c           | 709 ++++++++++++++++++++++++++++---
 drivers/net/dsa/lan9303.h                |  23 +
 drivers/net/dsa/lan9303_i2c.c            |   2 +
 drivers/net/dsa/lan9303_mdio.c           |  34 ++
 include/net/dsa.h                        |   1 +
 net/dsa/slave.c                          |  10 +
 7 files changed, 772 insertions(+), 70 deletions(-)
 create mode 100644 Documentation/networking/dsa/lan9303.txt

-- 
2.11.0

