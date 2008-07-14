From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 0/2] I/OAT: watchdog/reset and tcp_dma_copybreak
Date: Mon, 14 Jul 2008 15:27:59 +0200
Message-ID: <20080714132645.26941.64737.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13609 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516AbYGNNhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 09:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am resending these patches also to netdev list.

It has been a while since last ioatdma update.
Here are two patches that are a result of 
ioatdma sustaining and performance tuning efforts
for both I/OAT versions 1.2 and 2.0.

This patches apply to kernel 2.6.26-rc9.

Maciej Sosnowski (2):
     I/OAT: Add watchdog/reset functionality to ioatdma driver
     I/OAT: tcp_dma_copybreak default value dependant on I/OAT version

 drivers/dma/dmaengine.c   |    3 
 drivers/dma/ioat_dma.c    |  273 +++++++++++++++++++++++++++++++++++-
 drivers/dma/ioatdma.h     |   10 +
 include/linux/dmaengine.h |    2 
 4 files changed, 281 insertions(+), 7 deletions(-)

--
Maciej
