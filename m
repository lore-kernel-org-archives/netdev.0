From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 0/6] tc35815: driver update
Date: Fri, 11 Apr 2008 00:23:55 +0900 (JST)
Message-ID: <20080411.002355.08076156.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:63030 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760797AbYDJPXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:23:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is for tc35815 driver update, including many cleanups
and conversion to phylib.

* Statistics cleanup
* Use print_mac() helper
* Use netdev_priv()
* Use managed pci iomap helper
* Use generic PHY layer
* Whitespace cleanup

 drivers/net/Kconfig   |    2 +-
 drivers/net/tc35815.c | 1674 +++++++++++++++++--------------------------------
 2 files changed, 589 insertions(+), 1087 deletions(-)
