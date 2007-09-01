From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: 2.6.23-rc4-mm1
Date: Sat, 01 Sep 2007 17:25:27 +0530
Message-ID: <46D9532F.4080209@linux.vnet.ibm.com>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070901155353.8a09db69.kamezawa.hiroyu@jp.fujitsu.com> <20070831235815.a09c7865.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755221AbXIALzq@vger.kernel.org>
In-Reply-To: <20070831235815.a09c7865.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
>> On Sat, 1 Sep 2007 15:53:53 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> I met 2 troubles while I compiled rc4-mm1 on x86/UP system,
>>
>> One on pcnet32.c (patch is attaced below).
>> One on crypto CONFIG.
>>
>> == compile log ==
>> drivers/net/pcnet32.c: In function 'pcnet32_netif_stop':
>> drivers/net/pcnet32.c:445: warning: unused variable 'lp'
>> drivers/net/pcnet32.c: In function 'pcnet32_netif_start':
>> drivers/net/pcnet32.c:455: warning: unused variable 'lp'
>> drivers/net/pcnet32.c: In function 'pcnet32_interrupt':
>> drivers/net/pcnet32.c:2622: error: 'struct net_device' has no member named 'napi'
>>     
>
> Only git-net touches pcnet32.c
>
>   
<snip>
Hi Kamezawa,

I got the pcnet32.c compile failure and after applying the patch compile 
does not fails.

Thanks & Regards,
Kamalesh Babulal.
