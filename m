From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Fri, 18 Jun 2004 07:31:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617213130.GB14089@gondor.apana.org.au>
References: <20040616202341.GD29781@ms2.inr.ac.ru> <E1BajZO-0001UK-00@gondolin.me.apana.org.au> <20040617105843.314dfe30.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040617105843.314dfe30.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 10:58:43AM -0700, David S. Miller wrote:
>
> Do you see what xfrm_get_mss() does?  It calls into x->type->get_max_size()
> and this is where ESP reports this kind of thing (re: block padding).

Yes I know.  But this is only used in TCP currently.  It is also rather
expensive so you'd really want to cache the results rather than calling
it for every packet.

For example, xfrm4_check_tunnel_size() needs to use the value from
xfrm_get_mss() but isn't.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
