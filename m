From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: 17 Jan 2005 17:28:34 -0500
Message-ID: <1106000914.1046.4.camel@jzny.localdomain>
References: <20050116115431.GA13617@lst.de>
	 <20050117134228.5a6002a0.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, pavlic@de.ibm.com, waldi@debian.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050117134228.5a6002a0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Refer to my comments:
any device that ends up having to do that is a hack in my opinion;->
The dev_id maybe useful for other things. the qeth driver needs fixing
so it can stack the per-os instance interfaces.

cheers,
jamal

On Mon, 2005-01-17 at 16:42, David S. Miller wrote:
> On Sun, 16 Jan 2005 12:54:31 +0100
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > Let's try again solvign the EUI64 generation for S/390.  I looked over
> > the IBM patch and I think it can be done a lot simpler:
> > 
> >  - put a dev_id field in struct net_device, so that it uses space that
> >    would be wasted by padding otherwise.
> >  - if this fields is non-null let ipv6_generate_eui64 use the algorithm
> >    from the QETH code to generate an EUI that's different for each
> >    OS instance.  See code comments for details.
> 
> I'll apply this patch.
> 
> It might be nice to genericize that huge comment.  This will likely
> be not the last time we see devices which have this characteristic.
> 
> 
