From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Fri, 7 Apr 2017 16:08:08 +0300
Message-ID: <20170407130808.GA31087@splinter>
References: <20170406122303.30758-1-hch@lst.de>
 <20170406124320.GA5456@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60754 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756048AbdDGNIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 09:08:22 -0400
Content-Disposition: inline
In-Reply-To: <20170406124320.GA5456@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Thu, Apr 06, 2017 at 03:43:20PM +0300, Ido Schimmel wrote:
> On Thu, Apr 06, 2017 at 02:23:03PM +0200, Christoph Hellwig wrote:
> > Trivial conversion as only one vector is supported, but at least we
> > lose the useless msix_entry member in the per-device structure.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> For net-next:

I noticed this is marked as "Not Applicable" in patchwork:
https://patchwork.ozlabs.org/patch/747723/

But I'm not quite sure why. Maybe you meant to mark only v1?
https://patchwork.ozlabs.org/patch/747674/

Thanks
