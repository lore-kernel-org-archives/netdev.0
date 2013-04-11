From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: [PATCH 0/2 v2] changed irq handling for at86rf230
Date: Fri, 12 Apr 2013 00:16:12 +0200
Message-ID: <cover.1365716125.git.sascha@ps.nvbi.de>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	Sascha Herrmann <sascha@ps.nvbi.de>
To: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63921 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab3DKWQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 18:16:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Based on the feedback to the previous patch set, this patch set
makes the irq handling configurable. The first patch add the
option to configure the irq type of the plattform and the device.
The second patch changes the irq handling when edge type interrupts
are configured.

Without irq configuration of the irq type, the driver will remain
backward compatible.

Thanks,

Sascha Herrmann (2):
  at86rf230: add irq type configuration option
  at86rf230: change irq handling to prevent lockups with edge type irq

 drivers/net/ieee802154/at86rf230.c |   95 +++++++++++++++++++++++++-----------
 include/linux/spi/at86rf230.h      |   14 ++++++
 2 files changed, 81 insertions(+), 28 deletions(-)

-- 
1.7.10.4
