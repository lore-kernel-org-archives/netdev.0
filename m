From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Modular IPv6 support in tcpdiag
Date: Thu, 4 Nov 2004 07:32:27 +1100
Message-ID: <20041103203227.GA25279@gondor.apana.org.au>
References: <20041103094451.GA20220@gondor.apana.org.au> <20041103091609.7f6d5d9c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041103091609.7f6d5d9c@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2004 at 09:16:09AM -0800, Stephen Hemminger wrote:
> 
> I wanted to ask why all the work to make tcp_diag a module? If it is
> a module there are more possibilties of user problems. Any utilities
> that expect it would then have to deal with it not being loaded as well
> as the possiblity of building a kernel without it.

The reason is that prior to this if IPv6 was built as a module then
you couldn't have tcp_diag support for IPv6 sockets at all.

You're absolutely right about the potential problems with modules.
However, I did set the default to Y.

We should also have netlink module aliases so that these modules
can be loaded automatically by af_netlink.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
