From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH 0/3] can: m_can: add Bosch M_CAN controller support
Date: Fri, 27 Jun 2014 18:00:43 +0800
Message-ID: <1403863246-18822-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <wg@grandegger.com>,
	<mkl@pengutronix.de>, <devicetree@vger.kernel.org>
To: <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch series adds the basic function support for Bosch M_CAN controller

Dong Aisheng (3):
  can: m_can: add Bosch M_CAN controller support
  can: m_can: add bus error handling
  can: m_can: add loopback and monitor mode support

 .../devicetree/bindings/net/can/m_can.txt          |   29 +
 drivers/net/can/Kconfig                            |    5 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/m_can.c                            | 1096 ++++++++++++++++++++
 4 files changed, 1131 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/m_can.txt
 create mode 100644 drivers/net/can/m_can.c

-- 
1.7.8

