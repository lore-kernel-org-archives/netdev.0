From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH v2 0/5] ARCNET: add support for EAE multi interfac card
Date: Mon, 29 Sep 2014 11:55:33 +0200
Message-ID: <1411984538-953-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

this series adds support for the PLX Bridge based multi interface
pci cards and adds support to change device address on com200xx chips
during runtime.

This series is based on v3.17-rc7.
It is fixed for build against com20020_cs.

Thanks,
Michael


Michael Grzeschik (5):
  ARCNET: return IRQ_NONE if the interface isn't running
  ARCNET: add com20020_set_hwddr to change address
  ARCNET: add com20020 PCI IDs with metadata
  ARCNET: add support for multi interfaces on com20020
  ARCNET: enable eae arcnet card support

 drivers/net/arcnet/arcnet.c       |   2 +-
 drivers/net/arcnet/com20020-pci.c | 369 +++++++++++++++++++++++++++++---------
 drivers/net/arcnet/com20020.c     |  14 ++
 drivers/net/arcnet/com20020_cs.c  |   4 -
 include/linux/com20020.h          |  29 +++
 5 files changed, 330 insertions(+), 88 deletions(-)

-- 
2.1.0
