From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Sun, 16 Jan 2005 21:22:54 +0100
Message-ID: <20050116202254.GD22165@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <Pine.LNX.4.61.0501130944270.19573@netcore.fi> <20050113092351.GA23170@xi.wantstofly.org> <1105897020.1091.736.camel@jzny.localdomain> <20050116190227.GC21870@xi.wantstofly.org> <1105905906.1097.860.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Savola <pekkas@netcore.fi>, netdev@oss.sgi.com, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105905906.1097.860.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 03:05:06PM -0500, jamal wrote:

> > Apparently they mis-read the RFC and write the etherip header as 0x0300
> > instead of 0x3000 (they have the version nibble in the wrong place.)  This
> > would likely prevent interoperability.
> 
> Thinking about it a bit - you should be able to break yours to do 0x0300
> to test with them ;->

Etherip is a really simple standard, the header is only 16 bits which
can only assume a single value (0x3000).  Looking at encapsulated packets
with tcpdump makes me 99.99% confident that it's all okay on that level.


--L
