From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Wed, 1 Sep 2004 08:04:29 +0300 (EEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.58.0409010739510.1332@u.domain.uli>
References: <20040831111508.GA2327@gondor.apana.org.au>
	<Pine.LNX.4.44.0408311446240.4022-100000@l>
	<20040831212802.GB7058@gondor.apana.org.au>
	<20040831213318.GA7262@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	laforge@netfilter.org, rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040831213318.GA7262@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 1 Sep 2004, Herbert Xu wrote:

> > I was mistaken.  In the mpath case there is no source address per
> > nexthop.
>
> Actually, that should still work.
>
> For example, if you're like me and the nexthops all go to different
> devices then it's obviously OK as inet_select_addr will pick the
> right one for the device.  If they're going through the same device
> but to different gateways then it'll still pick the right one for
> the given gateway.

	Yes, if the targets are from some of the GW's subnets. It
is a masquerade drawback not to match by GW because the routing
does not support it but the world is not perfect.

Regards

--
Julian Anastasov <ja@ssi.bg>
