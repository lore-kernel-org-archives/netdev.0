From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 10:06:49 +0000
Message-ID: <20070130100649.GB8548@infradead.org>
References: <20070129060852.GA7814@lixom.net> <20070129223506.GA29068@electric-eye.fr.zoreil.com> <20070130014116.GB18935@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41204 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965435AbXA3KHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 05:07:05 -0500
Content-Disposition: inline
In-Reply-To: <20070130014116.GB18935@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 07:41:16PM -0600, Olof Johansson wrote:
> Maybe a bit of introduction could be useful (also regarding the
> pci_map/alloc comments below).
> 
> Our devices are on-chip, and while they're not on a PCI(e) bus internally,
> they do have config headers and will show up as devices on a pseudo-bus
> (the root one, in fact).
> 
> Also, while the driver could go through the IOMMU layers, there's no
> real use in doing so at this time.

sorry, but bypassing this is not what what we want in drivers at all.
In case you have an iommu and don't want it on the root bus chose
the noop dma implementation for this bus, which is easily possible on
powerpc.

