From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] 8139cp: set ring address before enabling receiver
Date: Fri, 01 Jun 2012 14:23:11 -0400 (EDT)
Message-ID: <20120601.142311.630705811475752099.davem@davemloft.net>
References: <20120601041939.4311.55827.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120601041939.4311.55827.stgit@dhcp-8-146.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 01 Jun 2012 12:19:39 +0800

> Currently, we enable the receiver before setting the ring address which could
> lead the card DMA into unexpected areas. Solving this by set the ring address
> before enabling the receiver.
> 
> btw. I find and test this in qemu as I didn't have a 8139cp card in hand. please
> review it carefully.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I hate bugs like this, the other common issue is enabling interrupts
before the chip is fully programmed.

Applied, thanks.
