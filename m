From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue
 immediately after it's detached from sk
Date: Fri, 08 Apr 2016 12:53:36 -0400 (EDT)
Message-ID: <20160408.125336.1805413467131988444.davem@davemloft.net>
References: <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
	<5707939B.2030907@huawei.com>
	<1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, netdev@vger.kernel.org,
	dingtianhong@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbcDHQxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:53:38 -0400
In-Reply-To: <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Apr 2016 07:44:25 -0700

> On Fri, 2016-04-08 at 19:18 +0800, Yang Yingliang wrote:
> 
>> I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.
> 
> Try :
> 
> echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
> 
> And restart your flows.

I'm honestly beginning to suspect a bug in their driver and how they
handle skb->truesize.

Yang, until you show us the driver you are using and how is handles
receive packets, we are largely in the dark about a major component
of this issue and that is entirely unfair to us.
