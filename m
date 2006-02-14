From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC,NETFILTER]: Fix xfrm lookup after SNAT
Date: Tue, 14 Feb 2006 12:49:24 +1100
Message-ID: <20060214014924.GA954@gondor.apana.org.au>
References: <43F0C0ED.8000303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43F0C0ED.8000303@trash.net>
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

On Mon, Feb 13, 2006 at 06:25:01PM +0100, Patrick McHardy wrote:
> I finally got around to fixing the "ip_finish_output2: No header cache
> and no neighbour!" problem reported by Andi Kleen. Instead of rerouting
> the packet in POST_ROUTING, we reuse the original route for the
> xfrm_lookup. This introduces a small restriction (see changelog entry),
> but I think it should work.
> 
> Herbert, do you see any problems with this patch?

Looks perfect to me.  I think the restriction makes sense since SNAT
is done in post-routing so it's counter-intuitive to repeat the lookup
anyway.
 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
