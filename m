From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Fri, 19 Mar 2004 22:47:57 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319114757.GD29066@gondor.apana.org.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF0E.3050708@trash.net> <20040318221523.07298f03.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040318221523.07298f03.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 18, 2004 at 10:15:23PM -0800, David S. Miller wrote:
> 
> Be careful!  xfrm4_tunnel handles both uncompressed ipcomp packets
> _and_ IPIP encapsulator device packets.  Yet you will intepret usage
> of the ipprot as 'xfrm_prot==1' in all cases.

Good point.

> Yes this is ugly... if we added some kind of flag bit-mask to sk_buff,
> would that allow an easier implementation?

I'm not sure if this'll help in the degenerate IPCOMP case.  Perhaps
we need a way to tell if it is a degenerate IPCOMP tunnel or an IPIP
tunnel without actually processing the packet.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
