From: John <linux.kernel@free.fr>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Fri, 02 Mar 2007 10:26:57 +0100
Message-ID: <45E7EDE1.30805@free.fr>
References: <45E5570E.7050301@free.fr> <200702281555.10309.dada1@cosmosbay.com> <45E5A8AE.3030606@free.fr> <200703011230.50596.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux.kernel@free.fr
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMT02001.global-sp.net ([193.168.50.54]:49738 "EHLO
	SMT02001.global-sp.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422982AbXCBJqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 04:46:35 -0500
In-Reply-To: <200703011230.50596.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:

> John wrote:
> 
>> Consider an idle Linux 2.6.20-rt8 system, equipped with a single PCI-E
>> gigabit Ethernet NIC, running on a modern CPU (e.g. Core 2 Duo E6700).
>> All this system does is time stamp 1000 packets per second.
>>
>> Are you claiming that this platform *cannot* handle most packets within
>> less than 1 microsecond of their arrival?
> 
> Yes I claim it. You expect too much of this platform, unless "most" means
> 10 % for you ;)

By "most" I meant more than 50%.

Has someone tried to measure interrupt latency in Linux? I'd like to 
plot the distribution of network IRQ to interrupt handler latencies.

> If you replace "1 us" by "50 us", then yes, it probably can do it, if "most" 
> means 99%, (not 99.999 %)

I think we need cold, hard numbers at this point :-)

> Anyway, if you want to play, you can apply this patch on top of 
> linux-2.6.21-rc2  (nanosecond resolution infrastructure needs 2.6.21)
> I let you do the adjustments for rt kernel.

Why does it require 2.6.21?

> This patch converts sk_buff timestamp to use new nanosecond infra
> (added in 2.6.21)

Is this mentioned somewhere in the 2.6.21-rc1 ChangeLog?
http://kernel.org/pub/linux/kernel/v2.6/testing/ChangeLog-2.6.21-rc1

Regards.
