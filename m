From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: Hack bench regression with CONFIG_SLUB_CPU_PARTIAL disabled (info
 only)
Date: Thu, 25 Jul 2013 18:50:58 +0530
Message-ID: <51F1263A.6070704@linux.vnet.ibm.com>
References: <51F0DB11.2080508@linux.vnet.ibm.com> <1374750359.23313.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:52171 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618Ab3GYNNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:13:47 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 23:05:53 +1000
In-Reply-To: <1374750359.23313.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2013 04:35 PM, Eric Dumazet wrote:
> On Thu, 2013-07-25 at 13:30 +0530, Raghavendra K T wrote:
>> Hi,
>>
>> While testing hackbench with 3.11-rc1 I observed hackbench testcase
>> took too long to complete (32 vcpu kvm guest on 32 core HT off machine).
>>
>> hackbench 1x degraded by 3 time (40sec vs 112sec)
>> hackbench 2x degraded by around 20time (90sec vs 1800 sec)
>>
>> When I bisected, I found that I had CONFIG_SLUB_CPU_PARTIAL
>> accidentally disabled.
>> I understand that  CONFIG_SLUB_CPU_PARTIAL=y by default and the config
>> option is to provide determinism for RT kernels and thus it is not a
>> problem.
>> But thought of sharing this here so that if somebody runs into same
>> issue accidently, it would save their time.
>
> Incidentally, what difference do you currently get with SLUB and SLAB ?
>

tested now,
hackbench 1x is  almost 2 times slower (40 vs 93)
hackbench 2x is almost 6times slower   (90sec vs 528)
