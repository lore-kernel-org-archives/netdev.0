From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: IPv6 badness continues
Date: Tue, 4 Jan 2005 10:33:35 +0100
Message-ID: <20050104093335.GB7823@xi.wantstofly.org>
References: <41DA3A60.8050102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DA3A60.8050102@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 04, 2005 at 01:40:32AM -0500, Jeff Garzik wrote:

> Standard FC2 OS with IPv6 6to4 setup as described on 
> http://linux.yyz.us/ipv6-fc2-howto.html

I upgraded my problematic machine to FC3, which somehow broke 6to4, and I
didn't bother to reenable it again because the local DNS server (dnscache)
just drops AAAA queries on the floor anyway, leading to lots of timeouts
when trying to resolve host names, etc.  Ever since 6to4 was turned off
on that box I stopped seeing these messages.


--L
