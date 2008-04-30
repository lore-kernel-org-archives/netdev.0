From: Jeff Garzik <jeff@garzik.org>
Subject: Re: odd RTL8139 quirk.
Date: Wed, 30 Apr 2008 07:13:48 -0400
Message-ID: <4818546C.4060703@garzik.org>
References: <20080429171403.GA21035@redhat.com>	<48177905.4000409@garzik.org>	<20080429215626.GC2859@redhat.com>	<48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51851 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756191AbYD3LOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 07:14:09 -0400
In-Reply-To: <20080429153240.7200e1a3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 29 Apr 2008 18:04:06 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Dave Jones wrote:
>>> On Tue, Apr 29, 2008 at 03:37:41PM -0400, Jeff Garzik wrote:
>>>  > Dave Jones wrote:
>>>  > > I've just been playing with a model 2 OQO, which has an RTL8139.
>>>  > > It gets detected just fine, though it doesn't actually work..
>>>  > > 
>>>  > > eth0: RealTek RTL8139 at 0xf8830000, 00:00:00:00:00:00, IRQ 18
>>>  > > eth0:  Identified 8139 chip type 'RTL-8139'
>>>  > > 
>>>  > > The null MAC address being one clue.  Another oddity is that
>>>  > > ethtool reports that there's no link detected, even though there is.
>>>  > > (Enough for it to PXE boot a kernel from at least :)
>>>  > > 
>>>  > > Futzing with the debug= modparam didn't yield anything extra at all.
>>>  > > 
>>>  > > Any clues?
>>>  > 
>>>  > Sounds like a broken EEPROM.  Does supplying a MAC via ifconfig prior to 
>>>  > 'ifconfig ... up' help?
>>>
>>> Ah. This sounds enlightening: http://www.oqotalk.com/index.php/topic,1511.0.html
>>> Seems a shame to have to choose PIO vs MMIO for a distro kernel though.
>>> Would there be any objection to turning that into a modparam ?
>>> (If we wanted to get really fancy, we could even quirk around it automatically
>>>  when we detect broken hardware).
>> Something like this?  :)
>>
>> http://www.linux.sgi.com/archives/netdev/2004-11/msg00226.html
>>
>> It did not go upstream but it needed some init-time bug fixing, IIRC. 
>> Maybe akpm remembers more why my patch sucked... :)
> 
> Apart from its From: address you mean? ;)
> 
> I can find no record, sorry.

Yeah, it was in -mm for a while (via netdev-2.6.git#ALL most likely), 
and a -mm tester reported that it consistently oops for him, or 
something along those lines.

You continually (and rightly!) pestered me about it, and I withdrew the 
patch from -mm since I didn't have time to futz with it.

	Jeff


