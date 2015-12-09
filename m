From: David Miller <davem@davemloft.net>
Subject: Re: next-20151207 - crash in IPv6 code
Date: Tue, 08 Dec 2015 21:15:34 -0500 (EST)
Message-ID: <20151208.211534.626369766229141448.davem@davemloft.net>
References: <3884.1449551563@turing-police.cc.vt.edu>
	<20151208113409.GA31055@breakpoint.cc>
	<4883.1449611657@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pablo@netfilter.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4883.1449611657@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis.Kletnieks@vt.edu
Date: Tue, 08 Dec 2015 16:54:17 -0500

> On Tue, 08 Dec 2015 12:34:09 +0100, Florian Westphal said:
>> Valdis Kletnieks <Valdis.Kletnieks@vt.edu> wrote:
>>
>> [ CC Pablo ]
>>
>> > Seen this in 2 boots out of two on next-20151207 when IPV6 networking
>> > was available.  It was stable when no net was available. Also, next-20161127 is OK.
>> > Haven't bisected it yet - this ring any bells?
>>
>> Thanks for the report, my fault -- its caused by
>> 029f7f3b8701cc7aca8bdb which is only in Pablos nf-next tree.
>>
>> This should fix this bug (proper patch w. changelog coming
>> after more testing):
>>
>> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
> 
> Pumped about 100M of IPv6 traffic through, and no problems.
> 
> Feel free to stick a Reported-by:/Tested-By: on this patch...

Thanks for testing.
