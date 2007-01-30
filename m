From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 10:03:58 +0000
Message-ID: <20070130100358.GA8548@infradead.org>
References: <20070129060852.GA7814@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55664 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965416AbXA3KER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 05:04:17 -0500
Content-Disposition: inline
In-Reply-To: <20070129060852.GA7814@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 12:08:52AM -0600, Olof Johansson wrote:
> Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)
> 
> Basic enablement, will be complemented with performance enhancements
> over time. PHY support will be added as well.
> 
> This patch still uses the numerical PCI vendor id, it will be replaced
> when the pci_ids.h change goes in (same as the other currently pending
> drivers).

>From a quick glance over the code you don't seem to handle memory allocation
erros at all, that needs some fixing.
