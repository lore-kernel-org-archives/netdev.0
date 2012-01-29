From: Ben Greear <greearb@candelatech.com>
Subject: Re: increase the number of routing tables
Date: Sat, 28 Jan 2012 18:46:01 -0800
Message-ID: <4F24B2E9.3010600@candelatech.com>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com> <1327804887.2805.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Chen <simonchennj@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46296 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab2A2CqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 21:46:08 -0500
In-Reply-To: <1327804887.2805.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2012 06:41 PM, Eric Dumazet wrote:
> Le samedi 28 janvier 2012 =C3=A0 21:20 -0500, Simon Chen a =C3=A9crit=
 :
>> Hey folks,
>>
>> To my limited knowledge, Linux currently supports 256 (255?) routing
>> tables defined in /etc/iproute2/rt_tables.
>>
>> Is there a way to increase this number to something much larger? Are
>> there performance/scalability concerns there? I am trying to have
>> customized routing table for each IP address (using "ip rule add fro=
m
>> xxx table yyy"). I am not sure exactly how many IPs I'll handle, but
>> certainly more than 255...
>>
>
> Its is possible, but probably not scalable.

I've run with a few thousand routing tables and probably 5000 or so
rules.  It seems to run OK....

> You really should not have too many "ip rule" entries, since they are
> evaluated linearly.

=46or every packet, or maybe just until conn-track gets an entry
for the connection?

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
