From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Sat, 30 Jan 2010 14:56:37 +0100
Message-ID: <op.u7cmcnxvp498uc@nexus>
References: <201001271556.16156.denys@visp.net.lb>
 <201001291715.57557.denys@visp.net.lb> <4B6356FF.7070504@tvk.rwth-aachen.de>
 <201001301535.43469.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7BIT
Cc: =?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:64419 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750879Ab0A3N4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 08:56:49 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KX20004KC2ODL20@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sat, 30 Jan 2010 14:56:48 +0100 (CET)
In-reply-to: <201001301535.43469.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Friday 29 January 2010 23:45:35 Damian Lukowski wrote:
>> Denys Fedoryshchenko schrieb:
>> > On Friday 29 January 2010 14:13:18 Damian Lukowski wrote:
>> >> Denys Fedoryshchenko schrieb:
>> >>> On Wednesday 27 January 2010 14:36:18 you wrote:
>> >>>> Unless they are for a different connection? We might have to print  
>> sk
>> >>>> (%p) in all those printouts to be sure which maps to which. If a  
>> peer
>> >>>> becomes unreachable, it may well have multiple connections open  
>> (this
>> >>>> was a proxy, iirc?).
>> >>>
>> >>> Ok i will try to do that today.
>> >>>
>> >>> Most probably different connections, on this proxy i have 10-15k
>> >>> established connections at peak time.
>> >
>> > http://www.nuclearcat.com/files/report1.txt
>> > http://www.nuclearcat.com/files/report2.txt
>> >
>> > Here with %p and sk.
>>
>> Ok, thanks for testing.
>> So it is ec0f3440 causing the trouble. Are there still objections
>> on the lower bound check in __tcp_set_rto()? Well, I will submit
>> an updated patch and you can make comments there.
> There is another sk also. I can catch for more time - there is many  
> different
> pointers to sk appearing (but not in same time, it is  rare case even  
> with my thousands of connections).

Hmm, I shouldn't have posted so late yesterday, as I forgot to CC
you and the others when submitting the patch, amongst the grammar error. :/
Can you test the patch in  
http://marc.info/?l=linux-netdev&m=126480336216898
please?

Damian
