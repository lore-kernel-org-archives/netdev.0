From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC,NETFILTER]: Fix xfrm lookup after SNAT
Date: Wed, 15 Feb 2006 01:34:39 -0800 (PST)
Message-ID: <20060215.013439.120363074.davem@davemloft.net>
References: <43F0C0ED.8000303@trash.net>
	<20060214014924.GA954@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20060214014924.GA954@gondor.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 14 Feb 2006 12:49:24 +1100

> On Mon, Feb 13, 2006 at 06:25:01PM +0100, Patrick McHardy wrote:
> > I finally got around to fixing the "ip_finish_output2: No header cache
> > and no neighbour!" problem reported by Andi Kleen. Instead of rerouting
> > the packet in POST_ROUTING, we reuse the original route for the
> > xfrm_lookup. This introduces a small restriction (see changelog entry),
> > but I think it should work.
> > 
> > Herbert, do you see any problems with this patch?
> 
> Looks perfect to me.  I think the restriction makes sense since SNAT
> is done in post-routing so it's counter-intuitive to repeat the lookup
> anyway.
>  
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good to me too, applied to net-2.6

Thanks a lot.
