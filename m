From: David Miller <davem@davemloft.net>
Subject: Re: -27% netperf TCP_STREAM regression by "tcp_memcontrol: Kill
 struct tcp_memcontrol"
Date: Tue, 22 Oct 2013 18:00:23 -0400 (EDT)
Message-ID: <20131022.180023.1141845387743361648.davem@davemloft.net>
References: <20131022214129.GB2715@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131022214129.GB2715@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fengguang.wu@intel.com
Date: Tue, 22 Oct 2013 22:41:29 +0100

> We noticed big netperf throughput regressions
> 
>     a4fe34bf902b8f709c63      2e685cad57906e19add7  
> ------------------------  ------------------------  
>                   707.40       -40.7%       419.60  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
>                  2775.60       -23.7%      2116.40  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
>                  3483.00       -27.2%      2536.00  TOTAL netperf.Throughput_Mbps
> 
> and bisected it to
> 
> commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date:   Sat Oct 19 16:26:19 2013 -0700
> 
>     tcp_memcontrol: Kill struct tcp_memcontrol

Eric please look into this, I'd rather have a fix to apply than revert your
work.

Thanks.
