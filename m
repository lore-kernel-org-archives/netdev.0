From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] ipv6: enable IPV6_FLOWLABEL_MGR for
 getsockopt
Date: Fri, 08 Nov 2013 13:43:24 -0500 (EST)
Message-ID: <20131108.134324.1679400843866741415.davem@davemloft.net>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<20131108122749.GA5876@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florent.fourcot@enst-bretagne.fr, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757406Ab3KHSn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:43:26 -0500
In-Reply-To: <20131108122749.GA5876@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 8 Nov 2013 13:27:49 +0100

> On Thu, Nov 07, 2013 at 05:53:12PM +0100, Florent Fourcot wrote:
>> It is already possible to set/put/renew a label
>> with IPV6_FLOWLABEL_MGR and setsockopt. This patch
>> add the possibility to get information about this
>> label (current value, time before expiration, etc).
>> 
>> It helps application to take decision for a renew
>> or a release of the label.
>> 
>> v2:
>>  * Add spin_lock to prevent race condition
>>  * return -ENOENT if no result found
>>  * check if flr_action is GET
>> 
>> v3:
>>  * move the spin_lock to protect only the
>>    relevant code
>> 
>> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> 
> There still are some locking anomalies in ip6_flowlabel. But none
> has something to do with your patches. E.g. mem_check runs without
> rcu_read_lock.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
