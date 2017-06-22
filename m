From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [GIT PULL] arcnet: fixes and features
Date: Thu, 22 Jun 2017 17:31:02 +0200
Message-ID: <20170622153110.4079-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53693 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752384AbdFVPbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 3d09198243b89457649241fb63f809a96a22a8ce:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-06-21 17:35:22 -0400)

are available in the git repository at:

  public@git.pengutronix.de:/mgr/linux.git tags/arcnet-for-mainline

for you to fetch changes up to 496890c2c34787290adaa50e204293d4fc4c98fc:

  arcnet: com20020-pci: add support for PCIFB2 card (2017-06-22 17:21:16 +0200)

----------------------------------------------------------------
arcnet: fixes and features

----------------------------------------------------------------
Michael Grzeschik (8):
      arcnet: change irq handler to lock irqsave
      arcnet: add err_skb package for package status feedback
      arcnet: com20020: remove needless base_addr assignment
      arcnet: com20020-pci: add missing pdev setup in netdev structure
      arcnet: com20020-pci: fix dev_id calculation
      arcnet: com20020-pci: add attribute to readback backplane status
      arcnet: com20020-pci: handle backplane mode depending on card type
      arcnet: com20020-pci: add support for PCIFB2 card

 drivers/net/arcnet/arcdevice.h    |  4 ++++
 drivers/net/arcnet/arcnet.c       | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/arcnet/com20020-pci.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/arcnet/com20020.c     |  2 --
 4 files changed, 134 insertions(+), 17 deletions(-)

-- 
2.11.0
