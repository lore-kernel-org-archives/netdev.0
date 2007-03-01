From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Thu, 01 Mar 2007 07:54:44 -0800
Message-ID: <45E6F744.8070106@linux-foundation.org>
References: <45E5570E.7050301@free.fr> <200702281555.10309.dada1@cosmosbay.com> <45E5A8AE.3030606@free.fr> <200703011230.50596.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John find <linux.kernel@free.fr>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57804 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933263AbXCAPzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 10:55:47 -0500
In-Reply-To: <200703011230.50596.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Wednesday 28 February 2007 17:07, John wrote:
>
>   
>> Consider an idle Linux 2.6.20-rt8 system, equipped with a single PCI-E
>> gigabit Ethernet NIC, running on a modern CPU (e.g. Core 2 Duo E6700).
>> All this system does is time stamp 1000 packets per second.
>>
>> Are you claiming that this platform *cannot* handle most packets within
>> less than 1 microsecond of their arrival?
>>     
>
> Yes I claim it.
>
> You expect too much of this platform, unless "most" means 10 % for 
> you ;)
>
> If you replace "1 us" by "50 us", then yes, it probably can do it, if "most" 
> means 99%, (not 99.999 %)
>
> Anyway, if you want to play, you can apply this patch on top of 
> linux-2.6.21-rc2  (nanosecond resolution infrastruture needs 2.6.21)
> I let you do the adjustments for rt kernel.
>
>   
I like it except changing stamp to stampns all over the place is 
unnecessary, just change the
type.

> I compiled it on my i386 machine, and tested it with a patched libpcap/tcpdump
>
>   
I assume old tcpdump works as expected.
