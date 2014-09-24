From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 0/5] ARCNET: add support for EAE multi interfac card
Date: Wed, 24 Sep 2014 15:41:48 +0200
Message-ID: <1411566113-15583-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

this series adds support for the PLX Bridge based multi interface
pci cards and adds support to change device address on com200xx chips
during runtime.

This series is based on v3.17-rc6.

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
 include/linux/com20020.h          |  29 +++
 4 files changed, 330 insertions(+), 84 deletions(-)

-- 
2.1.0
