From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next v2 0/6] net: Add STT support.
Date: Fri, 30 Jan 2015 08:46:04 -0800
Message-ID: <54CBB54C.2050307@hp.com>
References: <1422574156-1831-1-git-send-email-pshelar@nicira.com> <54CAFE89.4090509@gmail.com> <CALnjE+pPh5nSvaLTnM-a0r2Gm6K8Hz5BU_CsiWzYmwijPCOgHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2352.austin.hp.com ([15.217.128.51]:56417 "EHLO
	g2t2352.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbbA3QqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 11:46:10 -0500
In-Reply-To: <CALnjE+pPh5nSvaLTnM-a0r2Gm6K8Hz5BU_CsiWzYmwijPCOgHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2015 08:04 PM, Pravin Shelar wrote:
> On Thu, Jan 29, 2015 at 7:46 PM, Alexander Duyck
>> What does the small packet or non-TCP performance look like for STT vs
>> VXLAN?  My concern is that STT looks like it is a one trick pony since
>> all your numbers show is TCP TSO performance, and based on some of the
>> comments in your patches it seems like other protocols such as UDP are
>> going to suffer pretty badly due to things like the linearization overhead.
>>
>
> Current implementation is targeted for TCP workloads thats why I
> posted numbers with TCP, once UDP is optimized we can discuss UDP
> numbers. I am pretty sure the STT code can be optimized further
> specially for protocols other than TCP.

Not to pile-on or anything but indeed, there is much more to "TCP 
workloads" than just bulk transfer (TCP_STREAM), which is precisely why 
netperf was created oh so many years ago with its TCP_RR test to try to 
replace ttcp, and why there are the methods of mine and others to do 
aggregate PPS with it and other benchmarks.

Of course that comment applies not only to STT but also to any other 
"get to link-rate" on a (single|smallnumberof) stream" change.

rick
