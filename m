From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Sun, 21 Mar 2004 17:35:12 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040321063512.GE19697@gondor.apana.org.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040319115130.GE29066@gondor.apana.org.au> <405B2132.6060403@trash.net> <20040319210525.GA479@gondor.apana.org.au> <405C4ED3.4030004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <405C4ED3.4030004@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 20, 2004 at 03:01:55PM +0100, Patrick McHardy wrote:
> Herbert Xu wrote:
> >
> >Actually it was me who was confused.  ip_route_me_harder can be called
> >on both incoming/outgoing packets.  That's what the if clause is trying
> >to determine.  You should only call xfrm_lookup on the outgoing path.
> 
> No, ip_route_me_harder is currently (without the patches) only called
> for outgoing packets. The if-clause is there because ip_route_output
> doesn't handle packets with non-local source, and we don't want to set
> the source to 0 (as was done before) because it prevents policy routing
> from working properly. That's why we need the xfrm_lookup for both
> cases.

You're right.  Sorry for the confusion.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
