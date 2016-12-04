From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] act_mirred: fix a typo in get_dev
Date: Sat, 03 Dec 2016 19:28:37 -0500 (EST)
Message-ID: <20161203.192837.1824078815034576264.davem@davemloft.net>
References: <1480790161-8097-1-git-send-email-xiyou.wangcong@gmail.com>
        <1480791558.18162.406.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        hadarh@mellanox.com, jiri@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbcLDA2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:28:39 -0500
In-Reply-To: <1480791558.18162.406.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Dec 2016 10:59:18 -0800

> On Sat, 2016-12-03 at 10:36 -0800, Cong Wang wrote:
>> Cc: Hadar Hen Zion <hadarh@mellanox.com>
>> Cc: Jiri Pirko <jiri@mellanox.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/sched/act_mirred.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
>> index bb09ba3..2d9fa6e 100644
>> --- a/net/sched/act_mirred.c
>> +++ b/net/sched/act_mirred.c
>> @@ -321,7 +321,7 @@ static int tcf_mirred_device(const struct tc_action *a, struct net *net,
>>  	int ifindex = tcf_mirred_ifindex(a);
>>  
>>  	*mirred_dev = __dev_get_by_index(net, ifindex);
>> -	if (!mirred_dev)
>> +	if (!*mirred_dev)
>>  		return -EINVAL;
>>  	return 0;
>>  }
> 
> Fixes: 255cb30425c0 ("net/sched: act_mirred: Add new tc_action_ops get_dev()")
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
