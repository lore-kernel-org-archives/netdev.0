From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Change masquerade code to use first IP address
	of	interface.
Date: Wed, 20 Oct 2004 19:42:15 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <4176A377.8@trash.net>
References: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Rusty Russell <rusty@rustcorp.com.au> wrote:
>  
>
>>+       newsrc = inet_select_addr(out, 0, RT_SCOPE_UNIVERSE);
>>+       if (!newsrc) {
>>+               printk("MASQUERADE: %s ate my IP address\n", out->name);
>>+               return NF_DROP;
>>    
>>
>
>Wouldn't it be better to select the address for the gateway that we're
>sending towards?
>  
>

I agree. Rusty, I already have your patch queued in a
post-2.6.9 tree, I'm going to add Herbert's patch on top.

Regards
Patrick
