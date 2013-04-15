From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: [PATCH 0/2 v3] changed irq handling for at86rf230
Date: Mon, 15 Apr 2013 10:33:27 +0200
Message-ID: <cover.1366012862.git.sascha@ps.nvbi.de>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	Sascha Herrmann <sascha@ps.nvbi.de>
To: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:50047 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933045Ab3DOIdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 04:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to last version: Reordered local variable declarations.

The first patch add the option to configure the irq type of the
plattform and the device. The second patch changes the irq handling
when edge type interrupts are configured.

Without irq configuration of the irq type, the driver will remain
backward compatible.

Thanks,

Sascha Herrmann (2):
  at86rf230: add irq type configuration option
  at86rf230: change irq handling to prevent lockups with edge type irq

 drivers/net/ieee802154/at86rf230.c |   98 +++++++++++++++++++++++++-----------
 include/linux/spi/at86rf230.h      |   14 ++++++
 2 files changed, 82 insertions(+), 30 deletions(-)

-- 
1.7.10.4
