From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 0/2] Refactor lan9303_xxx_packet_processing
Date: Mon, 31 Jul 2017 13:33:53 +0200
Message-ID: <20170731113355.4284-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First patch: 
Change lan9303_enable_packet_processing,
lan9303_disable_packet_processing():
Pass port number (0,1,2) as parameter instead of port offset.
Plus replaced a constant 0x400 with LAN9303_SWITCH_PORT_REG()

Second patch: Simplify accordingly.

Comments welcome!

Egil Hjelmeland (2):
  net: dsa: lan9303: Refactor lan9303_xxx_packet_processing()
  net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage

 drivers/net/dsa/lan9303-core.c | 73 ++++++++++++++++++++----------------------
 1 file changed, 35 insertions(+), 38 deletions(-)

-- 
2.11.0
