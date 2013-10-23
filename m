From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: -27% netperf TCP_STREAM regression by "tcp_memcontrol: Kill struct tcp_memcontrol"
Date: Tue, 22 Oct 2013 21:38:10 -0700
Message-ID: <87k3h461ql.fsf@tw-ebiederman.twitter.com>
References: <20131022214129.GB2715@localhost>
	<20131022.180023.1141845387743361648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131022.180023.1141845387743361648.davem@davemloft.net> (David
	Miller's message of "Tue, 22 Oct 2013 18:00:23 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: fengguang.wu@intel.com
> Date: Tue, 22 Oct 2013 22:41:29 +0100
>
>> We noticed big netperf throughput regressions
>> 
>>     a4fe34bf902b8f709c63      2e685cad57906e19add7  
>> ------------------------  ------------------------  
>>                   707.40       -40.7%       419.60  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
>>                  2775.60       -23.7%      2116.40  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
>>                  3483.00       -27.2%      2536.00  TOTAL netperf.Throughput_Mbps
>> 
>> and bisected it to
>> 
>> commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
>> Author: Eric W. Biederman <ebiederm@xmission.com>
>> Date:   Sat Oct 19 16:26:19 2013 -0700
>> 
>>     tcp_memcontrol: Kill struct tcp_memcontrol
>
> Eric please look into this, I'd rather have a fix to apply than revert your
> work.

Will do I expect some ordering changed, and that changed the cache line
behavior.

If I can't find anything we can revert this one particular patch without
affecting anything else, but it would be nice to keep the data structure
smaller.

Fengguag what would I need to do to reproduce this?

Eric
