From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] kill drivers/net/net_init.c
Date: Thu, 18 Nov 2004 14:16:30 -0800
Message-ID: <20041118141630.490a4087.davem@davemloft.net>
References: <20041114101637.GA31739@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041114101637.GA31739@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 14 Nov 2004 11:16:37 +0100
Christoph Hellwig <hch@lst.de> wrote:

> After the last patch only three routines are left in this file, but all
> of the fir into net/core/dev.c much better:
> 
>  - {un,}register_netdev are just wrappers around {un,}register_netdevice
>    from dev.c
>  - alloc_netdev's counterpart, free_netdev is in dev.c aswell.
> 
> So move over the remaining contents and add some kerneldoc comments
> describing the functions.

Queued for 2.6.11, thanks Christoph.
