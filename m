From: Roman Yeryomin <roman@advem.lv>
Subject: Re: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 22 Oct 2017 23:57:55 +0300
Message-ID: <cc15f52b1f8d909b13b178b7abadb4dd@advem.lv>
References: <20171015162226.606-1-roman@advem.lv>
 <0FA80CB3-C0DC-4B30-B638-26B5D46AE69E@gmail.com>
 <c3a2f516dcceb7dee9ea4dde634b58ed@advem.lv>
 <20171015.140548.812014928035930297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:48596 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S932092AbdJVU56 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Oct 2017 16:57:58 -0400
In-Reply-To: <20171015.140548.812014928035930297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-16 00:05, David Miller wrote:
> From: Roman Yeryomin <roman@advem.lv>
> Date: Sun, 15 Oct 2017 19:46:02 +0300
> 
>> On 2017-10-15 19:38, Florian Fainelli wrote:
>>> On October 15, 2017 9:22:26 AM PDT, Roman Yeryomin <roman@advem.lv>
>>> wrote:
>>>> TX optimizations have led to ~15% performance increase (35->40Mbps)
>>>> in local tx usecase (tested with iperf v3.2).
>>> Could you avoid empty commit messages and write a paragraph or two 
>>> for
>>> each commit that explains what and why are you changing? The changes
>>> look fine but they lack any explanation.
>> 
>> I thought that short descriptions are already self explanatory and
>> just didn't know what to write more.
> 
> "Optimize TX handlers."
> 
> In what way?  Why?  How are things improved?  Is it measurable?
> etc.

OK, got the idea.
However I think I would need some help with measuring performance 
difference reliably.
On this CPU iperf3 tx takes most of the time (like 80-90%), thus even 
well optimized changes will be hard to see with iperf3 alone.
I've tried using pktgen module. Although it shows much better numbers 
than iperf3 (~95Mbps vs. 40), results don't look like very 
stable/reliable, pps may differ by 10-15% easily between different runs.
perf. I have limited experience with it but if I understand correctly, 
this CPU doesn't support neither cycles nor instructions counters. So 
not sure if perf would be useful here.

  Performance counter stats for 'system wide':

       10387.717082      cpu-clock (msec)          #    1.000 CPUs 
utilized
               2941      context-switches          #    0.283 K/sec
                  0      cpu-migrations            #    0.000 K/sec
                 60      page-faults               #    0.006 K/sec
    <not supported>      cycles
    <not supported>      instructions
    <not supported>      branches
    <not supported>      branch-misses

       10.388087500 seconds time elapsed


What are the suggestions?


Regards,
Roman
