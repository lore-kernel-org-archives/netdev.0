From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [NF+IPsec 1/6]: Remove okfn usage in ip_vs_core.c
Date: Sat, 22 Oct 2005 16:45:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0510221642100.16090@u.domain.uli>
References: <4352EEAB.8030708@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4352EEAB.8030708@trash.net>
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


	Hello,

On Mon, 17 Oct 2005, Patrick McHardy wrote:

> This is my current set of netfilter+IPsec patches with Herbert's
> suggestions incorporated. Changes since the last posted patches:
>
> - remove okfn use in ipvs and ip_conntrack to avoid deep
>    callchains with IPsec

	Such NF_STOP usage in IPVS looks ok

Acked-by: Julian Anastasov <ja@ssi.bg>

> - only pass packets to netfilter after tunnel mode transforms,
>    except for once in plain before encapsulation or after
>    decapsulation.
> - NAT support

Regards

--
Julian Anastasov <ja@ssi.bg>
