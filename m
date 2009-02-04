From: Wesley Chow <wchow@athenacr.com>
Subject: Re: Multicast packet loss
Date: Wed, 4 Feb 2009 11:46:35 -0500
Message-ID: <EA667848-C7EA-4409-B64D-9752C8ACECB6@athenacr.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <20090131160333.GC23100@localhost.localdomain> <498723D9.5020509@athenacr.com> <20090203115502.GB28117@hmsreliant.think-freely.org> <498860AD.5010702@athenacr.com> <20090204011541.GB3650@localhost.localdomain> <4989BD31.306@athenacr.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Kenny Chang <kchang@athenacr.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from li36-253.members.linode.com ([207.192.72.253]:38599 "EHLO
	shablam.senortoad.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757200AbZBDQqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 11:46:39 -0500
In-Reply-To: <4989BD31.306@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>>
>>>>>
>>>> Are these quad core systems?  Or dual core w/ hyperthreading?  I  
>>>> ask because in
>>>> your working setup you have 1/2 the number of cpus' and was not  
>>>> sure if you
>>>> removed an entire package of if you just disabled hyperthreading.
>>>>
>>>>
>>>> Neil
>>>>
>>>>
>>> Yeah, these are quad core systems.  The 8 cpu system is a dual- 
>>> processor  quad-core.  The other is my desktop, single cpu quad  
>>> core.
>>>
>>>


Just to be clear: on the 2 x quad core system, we can run with a  
2.6.15 kernel and see no packet drops. In fact, we can run with  
2.6.19, 2.6.20, and 2.6.21 just fine. 2.6.22 is the first kernel that  
shows problems.

Kenny posted results from a working setup on a different machine.

What I would really like to know is if whatever changed between 2.6.21  
and 2.6.22 that broke things is confined just to bnx2. To make this a  
rigorous test, we would need to use the same machine with a different  
nic, which we don't have quite yet. An Intel Pro 1000 ethernet card is  
in the mail as I type this.

I also tried forward porting the bnx2 driver in 2.6.21 to 2.6.22  
(unsuccessfully), and building the most recent driver from the  
Broadcom site to Ubuntu Hardy's 2.6.24. The most recent driver with  
hardy 2.6.24 showed similar packet dropping problems. Hm, perhaps I'll  
try to build the most recent broadcom driver against 2.6.21.


Wes

