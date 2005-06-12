From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 23:16:24 +1000
Message-ID: <20050612131624.GB10188@gondor.apana.org.au>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au> <20050612083409.GA8220@alpha.home.local> <20050612103020.GA25111@gondor.apana.org.au> <20050612114039.GI28759@alpha.home.local> <20050612120627.GA5858@gondor.apana.org.au> <20050612122247.GB22463@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <willy@w.ods.org>, davem@davemloft.net,
        xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050612122247.GB22463@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 02:22:47PM +0200, Thomas Graf wrote:
>
> > Look at the first check inside th->ack in tcp_rcv_synsent_state_process.
> 
> Usually a continious flow of ACK+RST is used to prevent a connection
> from being established, it's more reliable because even if you hit the
> ISS+rcv_next window the connection attempt will still be reset.

Sure.  My point is that there are a hundred and one ways to attack
a TCP connection in a manner similar to the original method that
started this thread.  So fixes like this are pretty pointless.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
