From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Mon, 17 Jan 2005 13:42:28 -0800
Message-ID: <20050117134228.5a6002a0.davem@davemloft.net>
References: <20050116115431.GA13617@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20050116115431.GA13617@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 16 Jan 2005 12:54:31 +0100
Christoph Hellwig <hch@lst.de> wrote:

> Let's try again solvign the EUI64 generation for S/390.  I looked over
> the IBM patch and I think it can be done a lot simpler:
> 
>  - put a dev_id field in struct net_device, so that it uses space that
>    would be wasted by padding otherwise.
>  - if this fields is non-null let ipv6_generate_eui64 use the algorithm
>    from the QETH code to generate an EUI that's different for each
>    OS instance.  See code comments for details.

I'll apply this patch.

It might be nice to genericize that huge comment.  This will likely
be not the last time we see devices which have this characteristic.
