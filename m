From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Mon, 10 Apr 2017 16:37:28 +0200
Message-ID: <20170410143728.GA14227@lst.de>
References: <20170407130808.GA31087@splinter> <20170407.071405.627036901988213530.davem@davemloft.net> <20170410073551.GA6036@lst.de> <20170410.070616.478356283361143853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, idosch@idosch.org, jiri@mellanox.com,
        idosch@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:50893 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753503AbdDJOhf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 10:37:35 -0400
Content-Disposition: inline
In-Reply-To: <20170410.070616.478356283361143853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 07:06:16AM -0700, David Miller wrote:
> My bad I thought this was part of that series.
> 
> Could you do me a favor and repost that series, with this mlxsw
> patch added to it.  I will apply it to net-next.

Note that mlxsw uses pci_enable_msix_exact which isn't going away
with the other series, only pci_enable_msix goes away for now.

But if you still want them together I'll happily repost.
