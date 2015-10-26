From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [GIT PULL v2] ARCNET: code simplification and features
Date: Mon, 26 Oct 2015 09:23:14 +0100
Message-ID: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37135 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbbJZIXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 04:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit d1611c3aba11ffa281bdd027aace52f5a370b8c5:

  bnxt_en: Fix compile warnings when CONFIG_INET is not set. (2015-10-25 22:36:15 -0700)

are available in the git repository at:

  git://git.pengutronix.de/git/mgr/linux.git tags/arcnet-for-4.4-rc1

for you to fetch changes up to 59fbcbc61e1f0fd9acdf3efb09faca0320049718:

  arcnet: add netif_carrier_on/off for reconnect (2015-10-26 09:10:56 +0100)

----------------------------------------------------------------
This series includes code simplifaction. The main changes are the correct
xceiver handling (enable/disable) of the com20020 cards. The driver now handles
link status change detection. The EAE PCI-ARCNET cards now make use of the
rotary encoded subdevice indexing and got support for led triggers on transmit
and reconnection events.

----------------------------------------------------------------
Michael Grzeschik (6):
      arcnet: move dev_free_skb to its only user
      arcnet: com20020: add enable and disable device on open/close
      arcnet: com20020-pci: set dev_port to the subdevice index
      arcnet: com20020-pci: add rotary index support
      arcnet: com20020-pci: add led trigger support
      arcnet: add netif_carrier_on/off for reconnect

 drivers/net/arcnet/arcdevice.h    |  21 ++++++++++++++++++++
 drivers/net/arcnet/arcnet.c       | 107 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/arcnet/com20020-pci.c | 107 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/arcnet/com20020.c     |  39 ++++++++++++++++++++++++++----------
 drivers/net/arcnet/com20020.h     |  14 +++++++++++++
 include/linux/leds.h              |   7 +++++++
 6 files changed, 277 insertions(+), 18 deletions(-)

Michael Grzeschik (6):
  arcnet: move dev_free_skb to its only user
  arcnet: com20020: add enable and disable device on open/close
  arcnet: com20020-pci: set dev_port to the subdevice index
  arcnet: com20020-pci: add rotary index support
  arcnet: com20020-pci: add led trigger support
  arcnet: add netif_carrier_on/off for reconnect

 drivers/net/arcnet/arcdevice.h    |  21 ++++++++
 drivers/net/arcnet/arcnet.c       | 107 +++++++++++++++++++++++++++++++++++---
 drivers/net/arcnet/com20020-pci.c | 107 ++++++++++++++++++++++++++++++++++++++
 drivers/net/arcnet/com20020.c     |  39 ++++++++++----
 drivers/net/arcnet/com20020.h     |  14 +++++
 include/linux/leds.h              |   7 +++
 6 files changed, 277 insertions(+), 18 deletions(-)

-- 
2.6.1
