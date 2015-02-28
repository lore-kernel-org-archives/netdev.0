From: Brian Rak <brak@vultr.com>
Subject: Re: Repeatable IPv6 crash in 3.19.0-1
Date: Fri, 27 Feb 2015 21:11:16 -0500
Message-ID: <54F123C4.2030907@vultr.com>
References: <54F0E38C.5060203@vultr.com>	 <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>	 <1425086169.5130.57.camel@edumazet-glaptop2.roam.corp.google.com>	 <54F11FC8.7010100@vultr.com>	 <1425088894.5130.60.camel@edumazet-glaptop2.roam.corp.google.com> <1425089025.5130.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.choopa.net ([216.155.136.52]:60115 "EHLO mail.choopa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbbB1CLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 21:11:16 -0500
In-Reply-To: <1425089025.5130.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2/27/2015 9:03 PM, Eric Dumazet wrote:
> On Fri, 2015-02-27 at 18:01 -0800, Eric Dumazet wrote:
>> On Fri, 2015-02-27 at 20:54 -0500, Brian Rak wrote:
>>
>>> Wow, that was *much* faster then I was expecting, thanks a bunch!
>>>
>>> I can confirm that resolves the issue.. I've tested this and it fixes
>>> the issue perfectly.  I've been able to put a whole bunch of IPv6
>>> traffic through the interface now, whereas before even a minor amount of
>>> traffic would crash the host.
>>>
>>> Thanks again!
>>
>> Interesting...
>>
>> Had a prior version of linux kernel been fine ?
>
> Or maybe you recently switched on this config option ?
>
> CONFIG_DEBUG_PAGEALLOC=y
>
>
>

We've only recently started using this veth/macvtap combo, so it's 
possible this has been around for awhile and we just hadn't noticed.

I don't have any info on older kernels currently.  I *think* I've seen 
crashes on 3.17.1, but I didn't save any stack traces, so I can't be sure.

CONFIG_DEBUG_PAGEALLOC is not set, and never has been.
