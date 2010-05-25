From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning in Linus' tree
Date: Mon, 24 May 2010 21:58:22 -0700 (PDT)
Message-ID: <20100524.215822.13254177.davem@davemloft.net>
References: <20100525114614.fd61d822.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, NeilJay@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100525114614.fd61d822.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 25 May 2010 11:46:14 +1000

> Hi Dave,
> 
> Today's linux-next build (x86_64 allmodconfig) produced this warning:
> 
> drivers/net/usb/asix.c: In function 'asix_rx_fixup':
> drivers/net/usb/asix.c:325: warning: cast from pointer to integer of different size
> drivers/net/usb/asix.c:354: warning: cast from pointer to integer of different size
> 
> Introduced by commit 3f78d1f210ff89af77f042ab7f4a8fee39feb1c9
> ("drivers/net/usb/asix.c: Fix unaligned accesses").  This commit casts
> skb->data to u32.

Thanks I'll look into this.
