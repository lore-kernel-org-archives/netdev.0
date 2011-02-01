From: Rick Jones <rick.jones2@hp.com>
Subject: Re: How To Temporarily Suspend Network Traffic
Date: Tue, 01 Feb 2011 12:03:31 -0800
Message-ID: <4D486713.70200@hp.com>
References: <87d3nbakwx.fsf@alamut.ozu.edu.tr> <4D4843B0.1090803@hp.com> <87ipx335e1.fsf@alamut.ozu.edu.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Volkan YAZICI <volkan.yazici@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:11912 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab1BAUDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 15:03:36 -0500
In-Reply-To: <87ipx335e1.fsf@alamut.ozu.edu.tr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Volkan YAZICI wrote:
> On Tue, 01 Feb 2011 09:32:32 -0800, Rick Jones writes:
> 
>>Out of not quite idle curiousity, what are you trying to accomplish?
> 
> I'm trying to implement a coarse-grained soft-TDMA (Time Division
> Multiple Access) among devices in a Wi-Fi network. (Coarse-grained, that
> is, compared to a hardware implementation.) Assuming that device clocks
> are in sync via NTP, I will figure out the granularity I can achieve
> with soft-TDMA.

As in Fred gets to transmit from 0 to N, Ethel gets to transmit from N+1 to 2N 
and so on, based on absolute time?

Getting small number of microsecond synchronization between multiple systems via 
NTP (particularly if they are synchronized via a wireless network) may prove 
challenging.  At least that is my take as a member of the peanut gallery reading 
over the shoulders of the discussions that take place in comp.protocols.time.ntp

>>Instead of using tc to set a zero rate, you could perhaps try using tc
>>to set a delay? If it doesn't offer microseconds of delay, pehaps
>>setting a delay and then eliminating it after your own pause will do
>>what you want - depends of course on what it is you really want.
> 
> Thanks for the advice. I'll check this out and see what I can do.
> 
>>Your saying you wanted microsecond granularity suggests you don't want
>>to suspend traffic for very long?
> 
> I want to figure out the smallest delay that I can achieve in a periodic
> manner. (E.g., freeze the traffic for 200us, continue without
> interruption for 800us, and freeze the traffic again for another 200us,
> etc.) Pay attention that, an undeterministic delay somewhere in between
> 1000us is not something I prefer, I must be able to determine the point
> in time where delay will appear -- ofcourse, with some error margin.

Sounds, well, challenging :)  The determining the point in time part in 
particular.  One thing I've learned is that the cell towers in a cell network 
sync their time directly to GPS with some kit that is non-trivially expensive.

rick jones

> 
> 
> Regards.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

