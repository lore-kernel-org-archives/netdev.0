From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Wed, 27 Apr 2005 21:35:42 +1000
Message-ID: <20050427113542.GB22433@gondor.apana.org.au>
References: <20050425213400.GB29288@gondor.apana.org.au>
	<426D8672.1030001@trash.net>
	<20050426003925.GA13650@gondor.apana.org.au>
	<426E3F67.8090006@trash.net>
	<20050426232857.GA18358@gondor.apana.org.au>
	<426EE350.1070902@trash.net>
	<20050427010730.GA18919@gondor.apana.org.au>
	<426F68C5.4010109@trash.net>
	<20050427103056.GB22099@gondor.apana.org.au>
	<Pine.LNX.4.58.0504271237350.4795@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org,
	Yair@arx.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0504271237350.4795@blackhole.kfki.hu>
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

On Wed, Apr 27, 2005 at 12:41:01PM +0200, Jozsef Kadlecsik wrote:
> > >
> > > Forwarded packets can't have any NAT manips in LOCAL_OUT, so it
> > > should work. I'm not sure about it though because it would be
> > > the only place where packets just appear in FORWARD, usually
> > > all packets enters through PRE_ROUTING or LOCAL_OUT.
> >
> > It's also the only place where we generate a packet with a non-local
> > source address :)
> 
> Besides the REJECT target, TARPIT in patch-o-matic-ng also generates
> packets with non-local source addresses. We cannot assume that REJECT is
> the only one which can create such packets.

Any reason why it can't be fed through the FORWARD chain as opposed
to LOCAL_OUT? In general, is there anything that's generating packets
with foreign addresses that can't be fed through FORWARD?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
