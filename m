From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [GIT PULL] ARCNET: features and fixes
Date: Fri, 16 Oct 2015 13:00:54 +0200
Message-ID: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: joe@perches.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:36501 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbbJPLBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 07:01:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 51161aa98d0aa4eb20952e16d6c6dbb1d085330e:

  net: Fix suspicious RCU usage in fib_rebalance (2015-10-16 00:57:55 -0700)

are available in the git repository at:

  git://git.pengutronix.de/git/mgr/linux.git tags/arcnet-v4.3-rc5

for you to fetch changes up to 908baca22086a76c7afa6e883f9aafef05fe9a01:

  arcnet: add netif_carrier_on/off for reconnect (2015-10-16 12:53:57 +0200)

----------------------------------------------------------------
This series includes some small fixes. The main changes are the correct
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
