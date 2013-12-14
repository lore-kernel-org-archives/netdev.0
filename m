From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from
 tc_action_ops
Date: Sat, 14 Dec 2013 00:15:29 -0500 (EST)
Message-ID: <20131214.001529.1872893184686335778.davem@davemloft.net>
References: <52AB87EB.6040508@mojatatu.com>
	<20131213.182325.2234215963739207753.davem@davemloft.net>
	<52ABC975.2070308@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, David.Laight@aculab.com,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab3LNFPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 00:15:31 -0500
In-Reply-To: <52ABC975.2070308@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 13 Dec 2013 21:59:01 -0500

> On 12/13/13 18:23, David Miller wrote:
> 
>> Jamal, nobody implements this interface, therefore these extra
>> stats are _NEVER_ provided.
>>
>> This is the end of the discussion, when there are in-tree users
>> of this method you can add it back.
> 
> Dave, I think that would be a good arguement if the feature was being
> provided in a new set of patches today.
> I dont see this as any different than removing an something from a
> UAPI header nobody knows any user of.

It is significantly different.

It is an internal kernel interface that was never used.

You cannot argue that, because it might have generated a netlink
attribute had it been implemented, that userland has a dependency upon
it.

You simply can't.
