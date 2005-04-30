From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPv6][IPsec] stop infinite loop
Date: Sat, 30 Apr 2005 13:11:59 +1000
Message-ID: <20050430031159.GA24326@gondor.apana.org.au>
References: <4272EC95.20401@miyazawa.org> <20050430.120736.45974367.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, davem@davemloft.net, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050430.120736.45974367.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 30, 2005 at 12:07:36PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> No, ipv6 depends on obsolete == -1; ip6_dst_check checks if dst is 
> up-to-date or not.
> 
> Please fix xfrm side; assumption that obsolete == 0.

Agreed.  I'll try to track it down.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
