From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: network namespace ipv6 perfs
Date: Tue, 04 Mar 2008 16:59:56 +0100
Message-ID: <47CD71FC.6010504@bull.net>
References: <47CC0920.6000005@fr.ibm.com> <47CC53C9.1000400@hp.com> <47CC590E.5070907@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:41002 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbYCDP7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 10:59:48 -0500
In-Reply-To: <47CC590E.5070907@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Rick Jones wrote:
>> Daniel Lezcano wrote:
>>> Hi,
>>>
>>> Some performance tests was made by Benjamin to watch out the impact 
>>> of the network namespace. The good news is there is no impact when 
>>> used with or without namespaces. That has been checked using a real 
>>> network device inside a network namespace.
>>
>> The *_RR tests seem to show a drop in througput and corresponding 
>> increases in service demand - could that be because things like TSO et 
>> al cannot mask much of anything in the way of a path-length increase?
> 
> Hmm. In fact Benjamin took the 2.6.23.16 kernel where there were no 
> network namespace code at all. So these differences between 2.6.23.16 
> and 2.6.25-rc1 does not show a performance degradation especially 
> related to the network namespaces. The important point is the 2.6.25-rc1 
> without ipv6 netns and 2.6.25-rc1 with ipv6 netns code applied, I mean 
> the second and the third line and we can point that the ipv6 netns code 
> does not degrade performances for either throughput and service demand.

As Daniel stated, we should not compare the first bar with the other
ones directly. May be I should have arranged the chart differently and
made it more clear that the first bar is "2.6.23 vanilla" and the second
one is "2.6.25-rc1 vanilla". Many changes happened in the whole kernel
between 2.6.23 and 2.6.24 so we can't compare the first two bars to tell
if network namespace degraded performances (and only a small part of
netns is in 2.6.24).
The way I presented the chart is a bit misleading. :)

What's interesting to compare in the charts is the 2nd, 3rd and 4th
lines. It shows that on the exact same hardware (in the 4th case the
physical interface is moved into the child namespace), with or without
the patchset, using network namespace or not, performance is about the
same.

Benjamin

>>  From the annotations, I'm ass-u-me-ing that NS was only used on the 
>> netperf side and not both netperf and netserver side?
> 
> right :)
> 
>> happy benchmarking,
> 
> Thanks Rick.
> 
>   -- Daniel
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
