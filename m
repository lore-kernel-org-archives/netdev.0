From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Change masquerade code to use first IP address
	of	interface.
Date: Wed, 20 Oct 2004 18:32:50 +1000
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
References: <1098241135.10571.19.camel@localhost.localdomain>
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: rusty@rustcorp.com.au (Rusty Russell)
In-Reply-To: <1098241135.10571.19.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> +       newsrc = inet_select_addr(out, 0, RT_SCOPE_UNIVERSE);
> +       if (!newsrc) {
> +               printk("MASQUERADE: %s ate my IP address\n", out->name);
> +               return NF_DROP;

Wouldn't it be better to select the address for the gateway that we're
sending towards?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
