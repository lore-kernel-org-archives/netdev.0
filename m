From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 0/4] arcnet: Collection of latest features
Date: Wed, 28 Jun 2017 18:32:17 +0200
Message-ID: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:54703 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752484AbdF1Qce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:32:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here we sum up the latest features to improve the arcnet framework. One
patch is used to get feedback from the transfer queue about failed xfers
by adding the err_skb message queue. Beside that we improve the
backplane status that can be read by the PCI-based cards and offer that
status via an extra sysfs attribute. In the last patch we add another
card type PCIFB2.

Michael Grzeschik (4):
  arcnet: add err_skb package for package status feedback
  arcnet: com20020-pci: add attribute to readback backplane status
  arcnet: com20020-pci: handle backplane mode depending on card type
  arcnet: com20020-pci: add support for PCIFB2 card

 drivers/net/arcnet/arcdevice.h    |  4 +++
 drivers/net/arcnet/arcnet.c       | 74 +++++++++++++++++++++++++++++++++------
 drivers/net/arcnet/com20020-pci.c | 58 ++++++++++++++++++++++++++++++
 3 files changed, 126 insertions(+), 10 deletions(-)

-- 
2.11.0
