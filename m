From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH A 00/12] Freescale ethernet driver updates
Date: Tue, 8 Jul 2014 00:21:48 +0100
Message-ID: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:57966 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751554AbaGGXVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 19:21:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here's the first batch of patches for the Freescale FEC ethernet driver.
They require the previously applied "net: fec: Don't clear IPV6 header
checksum field when IP accelerator enable" patch.

I'll mail further patches tomorrow, once I hear back from you.

Many thanks.

 drivers/net/ethernet/freescale/fec.h      |   1 -
 drivers/net/ethernet/freescale/fec_main.c | 137 +++++++++++++++++-------------
 2 files changed, 79 insertions(+), 59 deletions(-)

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
