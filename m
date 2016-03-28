From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: add proper locking in __inet{6}_lookup()
Date: Mon, 28 Mar 2016 11:27:10 -0400 (EDT)
Message-ID: <20160328.112710.2279688094912005224.davem@davemloft.net>
References: <1459171772.6473.86.camel@edumazet-glaptop3.roam.corp.google.com>
	<1459174213.6473.87.camel@edumazet-glaptop3.roam.corp.google.com>
	<1459175035.6473.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbcC1P1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 11:27:13 -0400
In-Reply-To: <1459175035.6473.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Mar 2016 07:23:55 -0700

> On Mon, 2016-03-28 at 07:10 -0700, Eric Dumazet wrote:
>> On Mon, 2016-03-28 at 06:29 -0700, Eric Dumazet wrote:
>> 
>> > Sure, but the caller changed quite a lot in all stable versions.
>> > 
>> > I took the easiest path for stable maintainers, and was planing to
>> > implement a better way in net-next.
>> 
>> I misread your suggestion David, I send a V2 shortly.
>> 
> 
> Actually, I'll wait for net-next opening.
> 
> My brain farted while working on the 'non refcounted TCP listener'
> because __inet_lookup_listener() will really need to be called from
> enclosed rcu_read_lock(), and for a reason I though net tree had a bug.
> 
> The local_bh_disable()/local_bh_enable() removal can certainly wait
> net-next.
> 
> Sorry for the confusion.

Ok, I'll mark this patch as deferred then.

Thanks Eric.
