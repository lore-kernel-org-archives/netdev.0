From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 07/13]: [NETFILTER]: Fix xfrm lookup in
	ip_route_me_harder/ip6_route_me_harder
Date: Tue, 29 Nov 2005 22:31:10 +1100
Message-ID: <20051129113110.GA20522@gondor.apana.org.au>
References: <20051128210628.GA15057@gondor.apana.org.au>
	<438BFD0A.5040105@trash.net>
	<20051129073441.GA18387@gondor.apana.org.au>
	<20051128.234947.117781000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051128.234947.117781000.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2005 at 11:49:47PM -0800, David S. Miller wrote:
> 
> I think #1 and #2 can be handled by an on-stack copy of "struct
> ip_options" high enough in the call chain, but #3 is a bit less
> trivial to cope with like that.
> 
> It would be nice to kill the IPCB() copy, and give us 12 bytes back in
> skb->cb[] :-)

That would be great.  I'm glad that Patrick's patch set is bringing
out potential ways of shrinking sk_buff.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
