From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH 0/8] SA11x0 DMA engine/IrDA updates
Date: Mon, 29 Aug 2016 12:25:41 +0100
Message-ID: <20160829112540.GF1041@n2100.armlinux.org.uk>
References: <20160829100232.GC1041@n2100.armlinux.org.uk>
 <20160829102328.GA28796@n2100.armlinux.org.uk>
 <20160829110157.GE1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vinod Koul <vinod.koul@intel.com>
To: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56828 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbcH2LZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:25:55 -0400
Content-Disposition: inline
In-Reply-To: <20160829110157.GE1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following on from the previous series of patches, this updates the
SA11x0 DMA engine code to use the modern method of lookup up DMA
channels, and converts the SA11x0 IrDA driver to use this.  We then
convert the SA11x0 IrDA driver to use gpiolib APIs to manipulate the
transceiver FIR mode select, power and range signals.

Obviously, as this is part of a larger series (and has dependencies
on the previous series) this can not be applied to individual
subsystem maintainer trees.

 arch/arm/mach-sa1100/assabet.c            | 44 ++++-----------
 arch/arm/mach-sa1100/collie.c             | 42 ++++----------
 arch/arm/mach-sa1100/generic.c            |  4 +-
 arch/arm/mach-sa1100/generic.h            |  3 +-
 arch/arm/mach-sa1100/h3100.c              | 48 ++++------------
 arch/arm/mach-sa1100/h3600.c              | 48 ++++------------
 drivers/dma/sa11x0-dma.c                  | 32 ++++++-----
 drivers/net/irda/sa1100_ir.c              | 91 ++++++++++++++++++++-----------
 include/linux/platform_data/irda-sa11x0.h | 20 -------
 include/linux/sa11x0-dma.h                | 24 --------
 10 files changed, 127 insertions(+), 229 deletions(-)
 delete mode 100644 include/linux/platform_data/irda-sa11x0.h
 delete mode 100644 include/linux/sa11x0-dma.h

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
