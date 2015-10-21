From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [GIT PULL] ARCNET: code simplification and features
Date: Wed, 21 Oct 2015 17:45:26 +0200
Message-ID: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:33023 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbJUPpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:45:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 6ac311ae8bfb47de09f349e781e26373944d2ee3:
  
  Adding switchdev ageing notification on port bridged (2015-10-21 07:50:57 -0700)

are available in the git repository at:
  
  ssh+git://git.pengutronix.de/git/mgr/linux.git tags/arcnet-for-4.4-rc1

for you to fetch changes up to d68c66a32f8176c27b9a395d07ba8a8e374f6111:
  
  arcnet: add netif_carrier_on/off for reconnect (2015-10-21 17:27:59 +0200)

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
 5 files changed, 270 insertions(+), 18 deletions(-)

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
 5 files changed, 270 insertions(+), 18 deletions(-)

-- 
2.6.1
