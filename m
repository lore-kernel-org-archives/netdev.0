From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patches
Date: Fri, 30 Jul 2004 12:22:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730022252.GA21689@gondor.apana.org.au>
References: <20040729181948.5d36f47f.davem@redhat.com> <20040730012431.GA21253@gondor.apana.org.au> <20040729192046.0a3fb71d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040729192046.0a3fb71d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 29, 2004 at 07:20:46PM -0700, David S. Miller wrote:
> 
> Based upon reading of the rest of the thread about
> this patch I understand that:
> 
> 1) Direction checking suggested by Yoshifuji is unecessary
>    because on input segments_left will be zero in the type 0
>    routing header.
> 
> 2) Both ipv4 and ipv6 erroneously do the xfrm route lookup
>    using the first hop destination not the final destination.
>    And this needs to be fixed with a followon patch.
> 
> Is this correct?

Yes.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
