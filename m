From: Christoph Hellwig <hch@lst.de>
Subject: remove dma_alloc_noncoherent V2
Date: Sat, 26 Aug 2017 09:21:21 +0200
Message-ID: <20170826072125.9790-1-hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>, linux-mips@vger.kernel.org,
        linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For many years we've had the dma_alloc_attrs API that is more flexible
than dma_alloc_noncoherent.  This series moves the remaining users over
to the attrs API.

After half of the series went in for the last merge window I'd really
like to merge the remainer.  Any chance to get some ACKs/reviews for
the net drivers?
