From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded
 ICMP errors from offending packet
Date: Tue, 1 Nov 2016 17:59:39 +0100
Message-ID: <ba90a129-bf47-f19b-07cf-e6a68c84aec7@stressinduktion.org>
References: <87bmxznsgg.fsf@redhat.com>
 <20161101.113505.1429989348222226550.davem@davemloft.net>
 <7f83a405-0520-a3ed-fc21-402d702483f9@stressinduktion.org>
 <20161101.123904.1432761986039949225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jkbs@redhat.com, tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101.123904.1432761986039949225.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.11.2016 17:39, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 1 Nov 2016 17:27:56 +0100
> 
>> On 01.11.2016 16:35, David Miller wrote:
>>> I have a really hard time accepting a "fix" that depends upon behavior
>>> that the Linux ipv6 stack doesn't even have.
>>
>> We actually support this feature:
> 
> But it is forbidden when the sysctl I mentioned is set, which is the
> default.
> 
> I'm talking about default behavior, which is to not reflect.

Oh, yes, understood.

I think we can flip this sysctl by default to off: current default
kernel config actually generates flow labels on its own, so the
description of this sysctl is violated by default anyway, as it doesn't
preserve the uniqueness anymore.

Bye,
Hannes
