From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sun, 6 Mar 2005 05:30:09 +1100
Message-ID: <20050305183009.GA26438@gondor.apana.org.au>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch> <20050305005911.GA27804@gondor.apana.org.au> <20050305162323.GM31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050305162323.GM31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 05, 2005 at 05:23:23PM +0100, Thomas Graf wrote:
> 
> Although we should keep the behaviour of ip a a 1.1.1.1/24; ip a d
> 1.1.1.1, what about ip a a 1.1.1.1/24; ip a d 1.1.1.1/16? I think the
> latter should not result in a deletion. We could achieve this by checking
> the prefix length if either the exact-match flag is set or the 
> prefixlength is != 32. This is of course quite minor and only affects
> old iproute2 versions in combination with newer kernels.

It's fine by me as long as the code doesn't get too complex because of it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
