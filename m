From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netpoll: call ->ndo_select_queue() in tx path
Date: Wed, 03 Oct 2012 14:39:21 -0400 (EDT)
Message-ID: <20121003.143921.697266851720404652.davem@davemloft.net>
References: <1347948991-20860-1-git-send-email-amwang@redhat.com>
	<20120919.172108.1539457128236567338.davem@davemloft.net>
	<CAF6-1L5Gp9kpV+Koru6uAmYxQg_WQav9RVD4MVBDa2UGSoPOCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, edumazet@google.com
To: s.munaut@whatever-company.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940Ab2JCSjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 14:39:24 -0400
In-Reply-To: <CAF6-1L5Gp9kpV+Koru6uAmYxQg_WQav9RVD4MVBDa2UGSoPOCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sylvain Munaut <s.munaut@whatever-company.com>
Date: Wed, 3 Oct 2012 11:33:22 +0200

> Hi,
> 
>>> In netpoll tx path, we miss the chance of calling ->ndo_select_queue(),
>>> thus could cause problems when bonding is involved.
>>>
>>> This patch makes dev_pick_tx() extern (and rename it to netdev_pick_tx())
>>> to let netpoll call it in netpoll_send_skb_on_dev().
>>>
>>> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: Eric Dumazet <edumazet@google.com>
>>> Signed-off-by: Cong Wang <amwang@redhat.com>
>>> Tested-by: Sylvain Munaut <s.munaut@whatever-company.com>
>>
>> Applied, thanks.
> 
> Huh, I don't see it in the final 3.6 ?
> That's rather inconvenient :(

What part of "net-next" in the subject line do you not understand?
