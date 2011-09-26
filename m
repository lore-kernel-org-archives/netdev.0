From: Rick Jones <rick.jones2@hp.com>
Subject: Re: intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 11:16:01 -0700
Message-ID: <4E80C161.1040204@hp.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J.Hwan.Kim" <j.hwan.kim99@gmail.com>, netdev@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: frog1120@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:12101 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447Ab1IZSQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 14:16:04 -0400
In-Reply-To: <4E809D59.10103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 08:42 AM, J.Hwan.Kim wrote:
> On 2011=EB=85=84 09=EC=9B=94 26=EC=9D=BC 23:20, Chris Friesen wrote:
>> On 09/26/2011 04:26 AM, J.Hwan Kim wrote:
>>> Hi, everyone
>>>
>>> Now, I'm testing a network card including intel 82599.
>>> In our experiment, with the driver modified with ixgbe and multi-po=
rt
>>> enabled,
>>
>> What do you mean by "modified with ixgbe and multi-port enabled"? Yo=
u
>> shouldn't need to do anything special to use both ports.
>>
>>> rx performance of each port with 10Gbps of 64bytes frame is
>>> a half than when only 1 port is used.
>>
>> Sounds like a cpu limitation. What is your cpu usage? How are your
>> interrupts routed? Are you using multiple rx queues?
>>
>
> Our server is XEON 2.4GHz with 8 cores.
> I'm using 4 RSS queues for each port and distributed it's interrupts =
to
> different cores respectively.
> I checked the CPU utilization with TOP, I guess ,it is not cpu imitat=
ion
> problem.

99 times out of 10, by default top will show the average CPU utilizatio=
n=20
across all the "CPUs" of the system. So I will ask the pedantic questio=
n=20
- Did you check per-CPU utilization or just overall?

rick jones
