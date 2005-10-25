From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Wed, 26 Oct 2005 09:10:49 +1000
Message-ID: <20051025231049.GA13679@gondor.apana.org.au>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
	<20051017014629.GB32661@gondor.apana.org.au>
	<435EBB18.50701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <435EBB18.50701@trash.net>
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

On Wed, Oct 26, 2005 at 01:09:12AM +0200, Patrick McHardy wrote:
>
> > So how about this? We let the SA tell us whether they want to go through
> > netfilter again.  So each SA will carry a flag which determines whether
> > packets through it should go through netfilter.
> > 
> > This flag would only affect transport mode SAs of course.
> 
> That would be one possibility. But I'm not a big fan of per-state flags
> that affect packet flow, so I think I'd prefer to just ignore this
> case. I don't think not handling inner transport mode SAs would be a
> big loss, so how about we just skip inner transport mode SAs completely
> on output and keep the input code as it is?

Actually I was thinking of transport mode SAs with no accompanying
tunnel mode SAs.  Did you have another way of dealing with them?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
