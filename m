From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sch_tbf: Fix potential memory leak in tbf_change().
Date: Wed, 26 Feb 2014 17:32:39 -0500 (EST)
Message-ID: <20140226.173239.307943125715907259.davem@davemloft.net>
References: <20140226214342.585acf597a84276fc152fc7e@gmail.com>
	<1393428584.2316.148.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shimoda.hiroaki@gmail.com, netdev@vger.kernel.org,
	yangyingliang@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbaBZWcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:32:41 -0500
In-Reply-To: <1393428584.2316.148.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Feb 2014 07:29:44 -0800

> On Wed, 2014-02-26 at 21:43 +0900, Hiroaki SHIMODA wrote:
>> The allocated child qdisc is not freed in error conditions.
>> Defer the allocation after user configuration turns out to be
>> valid and acceptable.
>> 
>> Fixes: cc106e4 ("net: sched: tbf: fix the calculation of max_size")
> 
> Please prefer/use 12 digits : cc106e441a63b

Applied with SHA1 adjustment, thanks.
