From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 10 Jul 2006 12:55:30 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0607101235430.2378@ask.diku.dk>
References: <4492D5D3.4000303@atmos.washington.edu> <200606260723.43209.ak@suse.de>
 <Pine.LNX.4.61.0607041333030.18483@ask.diku.dk> <200607041354.22472.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:53476 "EHLO mgw1.diku.dk")
	by vger.kernel.org with ESMTP id S1751351AbWGJKzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 06:55:35 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200607041354.22472.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 4 Jul 2006, Andi Kleen wrote:

> On Tuesday 04 July 2006 13:41, Jesper Dangaard Brouer wrote:
>>
>> Actually the change happens between kernel version 2.6.15 and 2.6.16.
>
> The timestamp optimizations are older. Don't remember the exact release,
> but earlier 2.6.

What I'm saying is that, with the same Config file, some Kconfig option 
changed between 2.6.15 and 2.6.16, that made my system use pmtmr for high-res 
timesource instead of TSC.


>> And
>> is a result of Andi's changes to arch/x86_64/Kconfig and
>> drivers/acpi/Kconfig, which "allows/activates" the use of the timer on
>> x86_64.
>
> Not sure what you mean here?

I think, that the changes you made to the files "arch/x86_64/Kconfig" and 
"drivers/acpi/Kconfig", caused this change...

commit: e78256b8f3e2850ad55c2d69e1429e6c2607afd3

http://www.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.17.y.git;a=commitdiff;h=e78256b8f3e2850ad55c2d69e1429e6c2607afd3

and maybe
commit: 2eb1bdbad89b19c99f8ac1de1492cdabbff6b3d3

http://www.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.17.y.git;a=commitdiff;h=2eb1bdbad89b19c99f8ac1de1492cdabbff6b3d3


Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
