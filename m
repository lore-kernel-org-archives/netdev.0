From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 0/5] arcnet: Collection of latest fixes
Date: Wed, 28 Jun 2017 18:28:32 +0200
Message-ID: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60745 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751650AbdF1Q2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here we sum up the recent fixes I collected on the way to use and
stabilise the framework. Part of it is an possible deadlock that we
prevent as well to fix the calculation of the dev_id that can be setup
by an rotary encoder. Beside that we added an trivial spelling patch and
fix some wrong and missing assignments that improves the code footprint.

Colin Ian King (1):
  Trivial fix to spelling mistake in arc_printk message

Michael Grzeschik (4):
  arcnet: change irq handler to lock irqsave
  arcnet: com20020: remove needless base_addr assignment
  arcnet: com20020-pci: fix dev_id calculation
  arcnet: com20020-pci: add missing pdev setup in netdev structure

 drivers/net/arcnet/arcnet.c       | 7 ++++---
 drivers/net/arcnet/capmode.c      | 2 +-
 drivers/net/arcnet/com20020-pci.c | 6 ++++--
 drivers/net/arcnet/com20020.c     | 2 --
 4 files changed, 9 insertions(+), 8 deletions(-)

-- 
2.11.0
