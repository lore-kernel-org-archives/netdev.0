From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 09:36:26 -0600
Message-ID: <20070130153626.GB25309@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070130100358.GA8548@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:37885 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965600AbXA3P3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 10:29:48 -0500
Content-Disposition: inline
In-Reply-To: <20070130100358.GA8548@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 10:03:58AM +0000, Christoph Hellwig wrote:
> On Mon, Jan 29, 2007 at 12:08:52AM -0600, Olof Johansson wrote:
> > Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)
> > 
> > Basic enablement, will be complemented with performance enhancements
> > over time. PHY support will be added as well.
> > 
> > This patch still uses the numerical PCI vendor id, it will be replaced
> > when the pci_ids.h change goes in (same as the other currently pending
> > drivers).
> 
> >From a quick glance over the code you don't seem to handle memory allocation
> erros at all, that needs some fixing.

v2 that I posted as a comment to the first one should have taken care
of most cases. I'll go through once more and see if I missed any before
posting a revised version later today.


Thanks,

-Olof
