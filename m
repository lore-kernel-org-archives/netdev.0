From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Fri, 4 May 2012 11:39:39 +0800
Message-ID: <4FA34F7B.1080402@mips.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com> <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:57540 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762Ab2EDDjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 23:39:45 -0400
In-Reply-To: <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 11:22 AM, Tom Herbert wrote:
>> +struct cpu_flow {
>> +       struct net_device *dev;
>> +       u32 rxhash;
>> +       unsigned long ts;
>> +};
>
> This seems like overkill, we already have the rps_flow_table and this
> used in accelerated RFS so the device can also take advantage of
> steering.  Maybe somehow program that table for your sparse flows?

In fact I did ever try something different in rps_flow_cnt (except for
rps_cpus, the only tunable thing relating to RPS in sysfs, am I missing
something?) and found no effect in my tests (iperf between 2 PCs via
Malta which works as router and uses iptables/NAT+RPS)...


Deng-Cheng
