From: Ben Greear <greearb@candelatech.com>
Subject: Re: SCTP performance?
Date: Fri, 09 Aug 2013 17:04:59 -0700
Message-ID: <520583AB.9030509@candelatech.com>
References: <52057734.6060306@candelatech.com> <1376090518.20509.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37418 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031651Ab3HJAFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 20:05:01 -0400
In-Reply-To: <1376090518.20509.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 04:21 PM, Eric Dumazet wrote:
> On Fri, 2013-08-09 at 16:11 -0700, Ben Greear wrote:
>> I just added some support for SCTP to my traffic-generator tool.
>>
>> I tried to send 1Gbps of traffic, bi-directional, across two
>> 10G interfaces.  TCP does this without any trouble at all,
>> but SCTP was asymetric and never got above around 700Mbps,
>> and was usually stuck at < 500Mbps.
>>
>> perf top didn't show any obvious CPU bottlenecks.
>>
>> Has anyone done any recent performance testing with SCTP?
>>
>> I'd be interested to know the results if so...
>
> You mean there is no SCTP offload on the NIC and/or GRO, yes that's too
> bad.
>

I'm sure that is part of the problem.

I got much better results when I explicitly set the
tx/rx socket buffer sizes to 2MB, so maybe it just sucks
at auto-tuning it's socket buffer sizes.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
