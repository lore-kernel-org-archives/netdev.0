From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Tue, 28 Oct 2014 15:58:26 -0400 (EDT)
Message-ID: <20141028.155826.702750675122810384.davem@davemloft.net>
References: <20141025004403.GC11289@acer.localdomain>
	<CAHA+R7NBr_K4fZ-nr2hi+isbxJt92D9o-q+n9xq5Y1rHv14F7Q@mail.gmail.com>
	<20141025010359.GD11289@acer.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, eric.dumazet@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	wang.bo116@zte.com.cn, john.r.fastabend@intel.com,
	edumazet@google.com, vtlam@google.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaJ1T63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 15:58:29 -0400
In-Reply-To: <20141025010359.GD11289@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 25 Oct 2014 02:04:00 +0100

>> Really, we don't have to make all ->init() doing cleanup by itself.
> 
> Are you seriously suggesting that it would be better to have ->destroy()
> check what parts were actually initialized and what needs to be cleaned
> up instead of assuming a consistent state and have the only function that
> actually knows the current state on error (->init()) do its own cleanup?
> 
> That's not even worth arguing about, its utterly and completely wrong.

I agree with Patrick here.
