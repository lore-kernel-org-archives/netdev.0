From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: remove delay at device dismantle
Date: Wed, 22 Aug 2012 19:51:11 -0700 (PDT)
Message-ID: <20120822.195111.765545116604962053.davem@davemloft.net>
References: <1344613369.31104.2734.camel@edumazet-glaptop>
	<1344664487.5158.1.camel@edumazet-glaptop>
	<5035947C.8090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, maheshb@google.com, ebiederm@xmission.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab2HWCvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:51:14 -0400
In-Reply-To: <5035947C.8090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 23 Aug 2012 10:25:00 +0800

> 于 2012年08月11日 13:54, Eric Dumazet 写道:
>> On Fri, 2012-08-10 at 17:42 +0200, Eric Dumazet wrote:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> I noticed extra one second delay in device dismantle, tracked down to
>>> a call to dst_dev_event() while some call_rcu() are still in RCU queues.
>>>
>> ...
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>> Cc: Tom Herbert <therbert@google.com>
>>> Cc: Mahesh Bandewar <maheshb@google.com>
>>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>>> ---
>>> v2: NETDEV_UNREGISTER_FINAL called outside of rtnl lock
>>>     as its more risky, base this patch on net-next
>> 
>> Also I am leaving for a one week vacation with no access to the
>> Internet, so better hold this patch until my return ;)
>> 
> 
> Hi Eric
> 
> I got this warning message with your patch applied.

Ok I won't push this out until this is resolved.
