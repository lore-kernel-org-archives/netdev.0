From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net/macb: Use dmapool to align descriptors on 64bits
Date: Mon, 3 Dec 2012 14:01:30 +0000
Message-ID: <1354543290.7030.26.camel@deadeye.wl.decadent.org.uk>
References: <1354536914-6315-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354536914-6315-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-12-03 at 13:15 +0100, Nicolas Ferre wrote:
> Depending on datapath, some revisions of GEM need
> 64bits aligned descriptors. Use dmapool to allocate
> these descriptors.
> Note that different size between RX and TX rings
> leads to the creation of two pools.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
[...]

dma_alloc_coherent() allocates whole pages, which I think is quite
enough alignment.  You can't save memory by doing this, since each pool
needs at least one page.  So what is this change meant to achieve?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
