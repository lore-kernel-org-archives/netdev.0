From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Tue, 19 Jan 2010 09:41:26 -0800
Message-ID: <4B55EEC6.4070402@hp.com>
References: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com>	<4B50B032.2060609@hp.com> <OFA56A461E.61811628-ON652576AD.0022D2A5-652576AD.002350AE@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:5179 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab0ASRl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 12:41:29 -0500
In-Reply-To: <OFA56A461E.61811628-ON652576AD.0022D2A5-652576AD.002350AE@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 wrote:
> Rick Jones <rick.jones2@hp.com> wrote on 01/15/2010 11:43:06 PM:
>>Multiple process tests may not be as easy in netperf as it is in
>>iperf, but under:
>>
>>ftp://ftp.netperf.org/netperf/misc
>>
>> I have a single-stream test script I use called runemomni.sh and an
>> example of its output, as well as an aggregate script I use called
>> runemomniagg2.sh - I'll post an example of its output there as
>> soon as I finish some runs.
> 
> 
> I usually run netperf for smaller number of threads and aggregate
> the output using some scripts. I will try what you suggested above,
> and see if I can get consistent results for higher number of
> processes. Thanks for the links.

You're welcome - the output of the aggregate script is up there too now 
- generally I run three systems for the aggregate tests and then include 
the TCP_MAERTs stuff, but in this case since I had only two otherwise 
identical systems, TCP_MAERTs would have been redundant.

rick jones
