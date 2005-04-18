From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Mon, 18 Apr 2005 18:09:02 +1000
Message-ID: <20050418080902.GA5675@gondor.apana.org.au>
References: <20050411125113.GL26731@postel.suug.ch> <E1DNLfx-0000yd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fmp@palmen.homeip.net, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <E1DNLfx-0000yd-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2005 at 12:07:49PM +1000, Herbert Xu wrote:
> 
> Indeed.  Here is a patch that adds the references that are held by
> the routes.

BTW, there are other problems in the appletalk stack that should
be fixed too.  For instance, the route entries and skb's there don't
hold a reference to the device that they point to.  So if anyone is
going to spend time on appletalk then they should have a look at them.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
