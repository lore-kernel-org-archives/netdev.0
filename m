From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] skb pcount with MTU discovery
Date: Sat, 2 Apr 2005 10:32:32 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0504021030120.21013@dexter.psc.edu>
References: <E1DHUvP-00050C-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DHUvP-00050C-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Apr 2005, Herbert Xu wrote:

> How about fixing tcp_snd_test directly like this?

I tried that first, but it caused a panic.  I assumed some other point in
the code assumed that invariant that if TSO is disabled then tso_segs==1.
I didn't investigate though.

> Of course all this will be moot once Dave finishes his TSO rewrite :)

That will make things much simpler. ;)

  -John
