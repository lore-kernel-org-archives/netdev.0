From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: xtables: stackptr should be percpu
Date: Mon, 31 May 2010 16:37:49 +0200
Message-ID: <4C03C9BD.2080907@trash.net>
References: <1275303998-2435-1-git-send-email-dfeng@redhat.com>  <alpine.LSU.2.01.1005311350580.31799@obet.zrqbmnf.qr> <1275311580.3291.44.camel@edumazet-laptop> <alpine.LSU.2.01.1005311519340.25402@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Xiaotian Feng <dfeng@redhat.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005311519340.25402@obet.zrqbmnf.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Monday 2010-05-31 15:13, Eric Dumazet wrote:
>> All cpus share a single cache line for their 'stackptr' storage,
>> introduced in commit f3c5c1bfd4
>>
>> This is a stable candidate (2.6.34)
> 
> Stackptr was first introduced for 2.6.35-rcX.
> 
>> +	i->stackptr = alloc_percpu(unsigned int);
>> 	if (i->stackptr == NULL)
>> 		return -ENOMEM;
>> -	memset(i->stackptr, 0, size);
>>
>> 	size = sizeof(void **) * nr_cpu_ids;
>> 	if (size > PAGE_SIZE)
> 
> Are alloc_percpu areas cleared?
> 
> Acked-By: Jan Engelhardt <jengelh@medozas.de>

Applied, thanks.
