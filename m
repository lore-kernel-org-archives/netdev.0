From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sat, 7 May 2005 22:25:04 +1000
Message-ID: <20050507122504.GA21693@gondor.apana.org.au>
References: <20050409105452.GA7171@gondor.apana.org.au> <20050507071434.GA5716@gondor.apana.org.au> <20050507071824.GA5753@gondor.apana.org.au> <20050507071930.GC5753@gondor.apana.org.au> <20050507072058.GD5753@gondor.apana.org.au> <20050507072139.GE5753@gondor.apana.org.au> <20050507072216.GF5753@gondor.apana.org.au> <20050507072251.GG5753@gondor.apana.org.au> <20050507072349.GH5753@gondor.apana.org.au> <1115467457.19561.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115467457.19561.5.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 07, 2005 at 08:04:16AM -0400, jamal wrote:
> 
> This is incosistent in two ways:
> 1) Typical netlink behavior is to return the object being deleted.
> Every other netlink user behaves that way - the only exception is sone
> filters in tc and this is because they cant retrieve that detail
> (something that needs resolution at some point). There is nothing that
> xfrm_usersa_id provides that can be found in xfrm_usersa_info.
> Same for the policy.

This analogy is flawed since unlike other rtnetlink delete operations
the xfrm delete operations do not carry the same payload type as their
add/update cousins.

> 2) You cant have one behavior when something is deleted by pfkey and a
> different one when it is deleted by netlink.

As far as I can see the behaviour is identical.

> So i would recommend pulling this one out.

Well I don't really have time to get into another debate so I'll
chuck this one out.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
