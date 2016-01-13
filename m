From: David Miller <davem@davemloft.net>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Wed, 13 Jan 2016 14:38:45 -0500 (EST)
Message-ID: <20160113.143845.2024795815995912436.davem@davemloft.net>
References: <1452546688.1223.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160113.110115.616973869173347041.davem@davemloft.net>
	<1452701990.1223.67.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gzhang@fastly.com, kernelorg@bof.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452701990.1223.67.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Jan 2016 08:19:50 -0800

> On Wed, 2016-01-13 at 11:01 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 11 Jan 2016 13:11:28 -0800
>> 
>> > David, can you make sure ed2e923945892a8372ab70d2f61d364b0b6d9054 is
>> > pushed to stable trees (4.1 & 4.2)
>> 
>> It should definitely be there:
>> 
>> [davem@localhost linux-stable]$ git shortlog v4.1.. -- include/net/inet_timewait_sock.h 
>> David S. Miller (1):
>>       Merge git://git.kernel.org/.../davem/net
>> 
>> Eric Dumazet (4):
>>       inet: simplify timewait refcounting
>>       inet: inet_twsk_deschedule factorization
>>       tcp/dccp: fix timewait races in timer handling
>>       net: align sk_refcnt on 128 bytes boundary
>> 
>> Raanan Avargil (1):
>>       tcp/dccp: fix old style declarations
>> 
> 
> Nothing yet on 4.1.15 and 4.2.8

I should really learn how to use GIT properly, thanks Eric I'll queue
the two patches up. :-)
