From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 0/16][BNX2]: Bug fixes and more 5709 suppot.
Date: Thu, 03 May 2007 00:27:44 -0700
Message-ID: <1178177264.4909.64.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1305 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754973AbXECGke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:40:34 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Version 2 of the BNX2 patchset.  I've modified the 40-bit workaround to
just set the dma masks, combined the 5709 firmware into 1 patch which is
now 500K, pulled out the heartbeat chnages, and separated the patch for
ethtool.h.  Earlier, I sent 1 patch for ethtool.h for the kernel, and
another patch for user mode ethtool to support 2.5G.

Thanks to David, Jeff, and others for their feedback.

[PATCH v2 1/16][BNX2]: Block MII access when ifdown.
[PATCH v2 2/16][BNX2]: Fix register and memory test on 5709.
[PATCH v2 3/16][BNX2]: Add 40-bit DMA workaround for 5708.
[PATCH v2 4/16][BNX2]: Fix race conditions when calling register_netdev().
[PATCH v2 5/16][BNX2]: Save PCI state during suspend.
[PATCH v2 6/16][BNX2]: Update 5708 firmware.
[PATCH v2 7/16][BNX2]: Update 5709 firmware.
[PATCH v2 8/16][BNX2]: Add ipv6 TSO and checksum for 5709.
[PATCH v2 9/16][BNX2]: Put MII register offsets in the bnx2 struct.
[PATCH v2 10/16][BNX2]: Re-structure the 2.5G Serdes code.
[PATCH v2 11/16][BNX2]: Add support for 5709 Serdes.
[PATCH v2 12/16][BNX2]: Add indirect spinlock.
[PATCH v2 13/16][BNX2]: Restructure PHY event handling.
[PATCH v2 14/16][BNX2]: Add 1-shot MSI handler for 5709.
[PATCH v2 15/16][BNX2]: Print bus information for PCIE devices.
[PATCH v2 16/16][BNX2]: Update version and reldate.


