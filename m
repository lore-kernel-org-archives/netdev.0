From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/9] netpoll: Cleanup received packet processing
Date: Fri, 14 Mar 2014 20:39:08 -0700
Message-ID: <87k3bwqgf7.fsf@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50208 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbaCODjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:39:15 -0400
In-Reply-To: <20140314.225923.61318448733570839.davem@davemloft.net> (David
	Miller's message of "Fri, 14 Mar 2014 22:59:23 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 14 Mar 2014 18:30:14 -0700
>
>> This is the long-winded, careful, and polite version of removing the netpoll
>> receive packet processing.
>> 
>> First I untangle the code in small steps.  Then I modify the code to not
>> force reception and dropping of packets when we are transmiting a packet
>> with netpoll.  Finally I move all of the packet reception under
>> CONFIG_NETPOLL_TRAP and delete CONFIG_NETPOLL_TRAP.
>> 
>> If someone wants to do a stable backport it would take backporting
>> the first 18 patches that handle the budget == 0 in the networking
>> drivers, and the first 5 of these patches.
>> 
>> If anyone wants to resurrect netpoll packet reception someday it should
>> just be a matter of reverting the last patch.
>
> This looks great, but it doesn't apply cleanly to net-next, please
> respin.

Doh!  It looks like I dropped the first patch by accident.
Resend coming up.


Eric
