From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH] Change masquerade code to use first IP address of
 interface.
Date: Wed, 20 Oct 2004 11:24:17 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0410201123200.25590@filer.marasystems.com>
References: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
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

On Wed, 20 Oct 2004, Herbert Xu wrote:

> Rusty Russell <rusty@rustcorp.com.au> wrote:
>>
>> +       newsrc = inet_select_addr(out, 0, RT_SCOPE_UNIVERSE);
>> +       if (!newsrc) {
>> +               printk("MASQUERADE: %s ate my IP address\n", out->name);
>> +               return NF_DROP;
>
> Wouldn't it be better to select the address for the gateway that we're
> sending towards?

What you mean?

It would surely not be sane to masquerade as the gateway we are sending 
towards.

Regards
Henrik
