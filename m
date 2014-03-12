From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 0/10] Using dev_kfree_skb_any for functions
 called in multiple contexts
Date: Wed, 12 Mar 2014 16:22:43 -0400 (EDT)
Message-ID: <20140312.162243.1752834713331952117.davem@davemloft.net>
References: <20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
	<1394592845.21721.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaCLUWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:22:45 -0400
In-Reply-To: <1394592845.21721.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 11 Mar 2014 19:54:05 -0700

> On Tue, 2014-03-11 at 14:13 -0700, Eric W. Biederman wrote:
>> This patchset should be an uncontroversial set of changes to change
>> dev_kfree_skb to dev_kfree_skb_any for code paths that are called in
>> hard irq contexts in addition to other contexts.  netpoll is the reason
>> this code gets called in multiple contexts.
>> 
>> There is more coming but these changes are a good starting place, and
>> stand on their own.
>> 
>> Since the last round changes to the rx path have been removed netpoll
>> will changed to avoid that.
>> 
>> Eric W. Biederman (10):
>>       8139cp: Call dev_kfree_skby_any instead of kfree_skb.
>>       8139too: Call dev_kfree_skby_any instead of dev_kfree_skb.
>>       r8169: Call dev_kfree_skby_any instead of dev_kfree_skb.
>>       bonding: Call dev_kfree_skby_any instead of kfree_skb.
>>       bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.
>>       tg3: Call dev_kfree_skby_any instead of dev_kfree_skb.
>>       ixgb: Call dev_kfree_skby_any instead of dev_kfree_skb.
>>       mlx4: Call dev_kfree_skby_any instead of dev_kfree_skb.
>>       benet: Call dev_kfree_skby_any instead of kfree_skb.
>>       gianfar: Carefully free skbs in functions called by netpoll.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> We'll have some follow up, but these patches seem fine.

Series applied, thanks everyone.
