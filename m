From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH] Change masquerade code to use first IP address of
 interface.
Date: Wed, 20 Oct 2004 13:04:51 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0410201300580.28452@filer.marasystems.com>
References: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
	<Pine.LNX.4.61.0410201123200.25590@filer.marasystems.com>
	<20041020104650.GA20868@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041020104650.GA20868@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004, Herbert Xu wrote:

> I mean
>
> 	rt = (struct rtable *)(*pskb)->dst;
> 	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_UNIVERSE);

IIRC we are not allowed to access this here, but I may be wrong.. If we 
are allowe to access the rtable like this then this is obviously better, 
and should also solve most policy routing setups (and allow the others to 
be solved).

Regards
Henrik
