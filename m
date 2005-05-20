From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sendmsg ignoring bind?
Date: Fri, 20 May 2005 20:17:49 +1000
Message-ID: <20050520101749.GA8661@gondor.apana.org.au>
References: <20050520081805.GR25658@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
Content-Disposition: inline
In-Reply-To: <20050520081805.GR25658@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 20, 2005 at 08:18:05AM +0000, Wichert Akkerman wrote:
>
> sendmsg(7, {msg_name(16)={sa_family=AF_INET, sin_port=htons(1812),
> 	sin_addr=inet_addr("212.100.254.89")},
> 	msg_iov(1)=[{"....", 249}], msg_controllen=24, {cmsg_len=24,
> 	cmsg_level=SOL_IP, cmsg_type=, ...}, msg_flags=0}, 0) = 249

This could be a cmsg option that overrode the bind address.  Please
decode it so that we know what it's doing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
