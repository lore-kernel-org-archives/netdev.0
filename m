From: chenweilong <chenweilong@huawei.com>
Subject: Re: [patch net-next v2 7/7] ipv4: ERROR: do not use C99 // comments
Date: Mon, 23 Dec 2013 11:56:10 +0800
Message-ID: <52B7B45A.5040805@huawei.com>
References: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>	 <1387764856-13948-8-git-send-email-chenweilong@huawei.com> <1387767575.22671.46.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<pablo@netfilter.org>, <kadlec@blackhole.kfki.hu>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20746 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649Ab3LWD5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 22:57:00 -0500
In-Reply-To: <1387767575.22671.46.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/23 10:59, Joe Perches wrote:
> On Mon, 2013-12-23 at 10:14 +0800, Chen Weilong wrote:
>> From: Weilong Chen <chenweilong@huawei.com>
> []
>> diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
> []
>> @@ -15,13 +15,13 @@
>>  
>>  #include "tcp_vegas.h"
>>  
>> -#define TCP_YEAH_ALPHA       80 //lin number of packets queued at the bottleneck
>> -#define TCP_YEAH_GAMMA        1 //lin fraction of queue to be removed per rtt
>> -#define TCP_YEAH_DELTA        3 //log minimum fraction of cwnd to be removed on loss
>> -#define TCP_YEAH_EPSILON      1 //log maximum fraction to be removed on early decongestion
>> -#define TCP_YEAH_PHY          8 //lin maximum delta from base
>> -#define TCP_YEAH_RHO         16 //lin minimum number of consecutive rtt to consider competition on loss
>> -#define TCP_YEAH_ZETA        50 //lin minimum number of state switchs to reset reno_count
>> +#define TCP_YEAH_ALPHA       80 /* lin number of packets queued at the bottleneck */
>> +#define TCP_YEAH_GAMMA        1 /* lin fraction of queue to be removed per rtt */
>> +#define TCP_YEAH_DELTA        3 /* log minimum fraction of cwnd to be removed on loss */
>> +#define TCP_YEAH_EPSILON      1 /* log maximum fraction to be removed on early decongestion */
>> +#define TCP_YEAH_PHY          8 /* lin maximum delta from base */
>> +#define TCP_YEAH_RHO         16 /* lin minimum number of consecutive rtt to consider competition on loss */
>> +#define TCP_YEAH_ZETA        50 /* lin minimum number of state switchs to reset reno_count */
> 
> Does anyone actually use this?
> Does "lin" add anything useful?
> lin should probably be removed otherwise.
> What does it mean anyway? link?  linear?
> 
> The link to the paper in the file is dead.
> http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
> 
> archive.org has it at:
> https://web.archive.org/web/20080316215752/http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
> 
> btw, spelling: s/switchs/switches/
> 
> 
> .
> 
Thanks for pointing out shortcomings in my patch,I'll fix it.

I agree with you that 'lin' can be removed.
I think 'lin' means 'socket link', according to the code,they are used for 'struct yeah',that is placed in
each 'struct sock'.
