From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Mon, 17 Jan 2005 14:42:59 -0800
Message-ID: <20050117144259.7882e629.davem@davemloft.net>
References: <20050116115431.GA13617@lst.de>
	<20050117134228.5a6002a0.davem@davemloft.net>
	<1106000914.1046.4.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106000914.1046.4.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Jan 2005 17:28:34 -0500
jamal <hadi@cyberus.ca> wrote:

> Refer to my comments:
> any device that ends up having to do that is a hack in my opinion;->
> The dev_id maybe useful for other things. the qeth driver needs fixing
> so it can stack the per-os instance interfaces.

I agree but...

At least Christian's patch is 100 times cleaner than what IBM
has proposed.  People have been "talking" endlessly about providing
a clean version of the infrastructure necessary to support what
qeth needs for EUI64 generation, but everyone did nothing but
talk and suggest.

Christian backed up his "talk" with "code", and since his changes
aren't that unreasonable they go in :-)
