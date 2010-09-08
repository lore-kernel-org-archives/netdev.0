From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rps: add the shortcut for one rps_cpus
Date: Wed, 08 Sep 2010 13:11:21 -0700 (PDT)
Message-ID: <20100908.131121.260074669.davem@davemloft.net>
References: <1283591557-31921-1-git-send-email-xiaosuo@gmail.com>
	<1283598071.3402.21.camel@edumazet-laptop>
	<AANLkTik8EXfzTzJGBu9pQKQUO6WQM9p1gmr64vkQjA64@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47543
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753636Ab0IHULD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:11:03 -0400
In-Reply-To: <AANLkTik8EXfzTzJGBu9pQKQUO6WQM9p1gmr64vkQjA64@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 4 Sep 2010 20:18:20 +0800

> On Sat, Sep 4, 2010 at 7:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> You are 'optimizing' a very unusual case and slow down 99% of normal
>> uses.
>>
>> Normal way to handle this, is to use irq affinity and deliver interrupts
>> directly to the target cpu.
>>
>>
> 
> Some pseudo network devices may share the same interrupt, such as vlan
> network devices. In this case, setting the IRQ affinity can't work.

I'm fine with this patch being in net-next-2.6 for now, so I've
applied it, thanks.
