From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix possible seqlock deadlock in
 ip6_finish_output2
Date: Sat, 30 Nov 2013 12:49:05 -0500 (EST)
Message-ID: <20131130.124905.1525994055463627833.davem@davemloft.net>
References: <20131128192231.GE24171@order.stressinduktion.org>
	<20131129053944.GH24171@order.stressinduktion.org>
	<1385829955.5352.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jongman.heo@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385829955.5352.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Nov 2013 08:45:55 -0800

> On Fri, 2013-11-29 at 06:39 +0100, Hannes Frederic Sowa wrote:
>> IPv6 stats are 64 bits and thus are protected with a seqlock. By not
>> disabling bottom-half we could deadlock here if we don't disable bh and
>> a softirq reentrantly updates the same mib.
>> 
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> (Note that the seqlock is only for 32bit arches)

Applied and queued up for -stable, thanks.
