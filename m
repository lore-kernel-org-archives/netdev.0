From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: IPv6 badness continues
Date: Wed, 5 Jan 2005 11:19:55 +0100
Message-ID: <20050105101955.GE19910@xi.wantstofly.org>
References: <41DA3A60.8050102@pobox.com> <20050104093335.GB7823@xi.wantstofly.org> <Pine.LNX.4.61.0501042254330.30839@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0501042254330.30839@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 04, 2005 at 10:57:43PM +0200, Pekka Savola wrote:

> >I upgraded my problematic machine to FC3, which somehow broke 6to4, and I
> >didn't bother to reenable it again because the local DNS server (dnscache)
> >just drops AAAA queries on the floor anyway, leading to lots of timeouts
> >when trying to resolve host names, etc.  Ever since 6to4 was turned off
> >on that box I stopped seeing these messages.
> 
> Surely it doesn't just drop AAAA queries on the floor, but sends an 
> error message?

Sorry, I just tried again and can't reproduce this behavior -- when doing
an AAAA query on a random domain name I get a clean 0/0/0 answer indicating
no RRs of the desired type having been found, and doing an AAAA query on a
domain name that does have RRs of that type, I do get the desired records.

I'm trying to recall what specific problem it was that I was seeing..


--L
