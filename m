From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Sat, 12 Mar 2005 08:21:28 +1100
Message-ID: <E1D9rZX-0004KE-00@gondolin.me.apana.org.au>
References: <4232044E.8030001@trash.net>
Cc: netdev@oss.sgi.com, dtor_core@ameritech.net,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <4232044E.8030001@trash.net>
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

Patrick McHardy <kaber@trash.net> wrote:
> 
> You're right, good catch. IPT_RETURN is interpreted internally by
> ip_tables, but since the value changed it isn't recognized by ip_tables
> anymore and returned to nf_iterate() as NF_REPEAT. This patch restores
> the old value.

Please fix netfilter_arp while you're at it since it does exactly
the same thing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
