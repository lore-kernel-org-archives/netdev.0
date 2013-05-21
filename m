From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 19:51:37 +0400
Message-ID: <519B9809.1010408@yandex-team.ru>
References: <519B38EC.90401@yandex-team.ru>   <20130521120906.GD3578@linux.vnet.ibm.com>  <1369143885.3301.221.camel@edumazet-glaptop>  <519B8908.9080007@yandex-team.ru> <1369150693.3301.233.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369150693.3301.233.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.05.2013 19:38, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 18:47 +0400, Roman Gushchin wrote:
>
>> This code has the same mistake: it is rcu_dereference_raw(head->first),
>> so there is nothing that prevents gcc to store the (head->first) value
>> in a register.
>
> If other rcu accessors have the same problem, a more complete patch is
> needed.

Ok, I'll try to provide a complete patch ASAP.

>
> Thanks
>
>
>
