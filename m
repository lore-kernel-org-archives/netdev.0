From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: remove delay at device dismantle
Date: Wed, 22 Aug 2012 19:18:44 -0700 (PDT)
Message-ID: <20120822.191844.1123287169091599224.davem@davemloft.net>
References: <1344609966.31104.2705.camel@edumazet-glaptop>
	<1344613369.31104.2734.camel@edumazet-glaptop>
	<1344664487.5158.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, maheshb@google.com,
	ebiederm@xmission.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab2HWCSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:18:45 -0400
In-Reply-To: <1344664487.5158.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 11 Aug 2012 07:54:47 +0200

> On Fri, 2012-08-10 at 17:42 +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> I noticed extra one second delay in device dismantle, tracked down to
>> a call to dst_dev_event() while some call_rcu() are still in RCU queues.
>> 
> ...
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Tom Herbert <therbert@google.com>
>> Cc: Mahesh Bandewar <maheshb@google.com>
>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>> v2: NETDEV_UNREGISTER_FINAL called outside of rtnl lock
>>     as its more risky, base this patch on net-next
> 
> Also I am leaving for a one week vacation with no access to the
> Internet, so better hold this patch until my return ;)

Since you're back, I've applied this now.

Thanks.
