From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Tue, 26 Apr 2005 07:34:00 +1000
Message-ID: <20050425213400.GB29288@gondor.apana.org.au>
References: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
	<426D0CB9.4060500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <426D0CB9.4060500@trash.net>
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

On Mon, Apr 25, 2005 at 05:28:57PM +0200, Patrick McHardy wrote:
> 
> No, ip_route_me_harder() can be called for packets with non-local
> source. ip_route_output_slow() rejects non-local source addresses,
> so the only way to use them for policy routing is by using
> ip_route_input().

You're right.  But then we can't call ip_route_output in the case
where saddr is foreign but daddr is local.  Nor can we call
ip_route_input since the output will be ip_rt_bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
