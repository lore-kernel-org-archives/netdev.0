From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Mon, 22 Mar 2004 03:29:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405E4F99.7060605@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040321221604.GA32277@gondor.apana.org.au> <405E2673.4090808@trash.net> <20040322020322.GA1187@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040322020322.GA1187@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Mar 22, 2004 at 12:34:11AM +0100, Patrick McHardy wrote:
>
>>Is it correct that __xfrm_route_forward will use NULL for the sock
>>parameter to xfrm_lookup even if the packet is from a local socket ?
> 
> No that would be wrong as socket policies won't be applied correctly.
> Forget about that idea :)

Thanks anyway, it reminded me to check for !(dst->flags & DST_NOXFRM)
before xfrm_lookup, I'm going to change this now.

Regards
Patrick
