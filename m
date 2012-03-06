From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Tue, 06 Mar 2012 10:23:56 -0800
Message-ID: <4F56563C.2070206@hp.com>
References: <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120217.133327.1178765872497293871.davem@davemloft.net> <1330656317.21053.1411.camel@debian> <20120301.220743.2174015405223036036.davem@davemloft.net> <20120306081117.GA17375@feng-i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alex.shi@intel.com,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	tim.c.chen@intel.com, ying.huang@intel.com, netdev@vger.kernel.org
To: Feng Tang <feng.tang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120306081117.GA17375@feng-i7>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/2012 12:11 AM, Feng Tang wrote:
> On some machines, we found there is about 10% resgression of netperf
> TCP-64K loopback test between 3.2 and 3.3-rc1. The exact test is:
> ./netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -i 50,3 -I 99,5 -- -s 32768 -S 32768 -m 4096

Side comment on the netperf command line.  The maximum confidence 
interactions is silently capped at 30, so that might as well be "-i 
30,3" 
http://www.netperf.org/svn/netperf2/tags/netperf-2.5.0/doc/netperf.html#index-g_t_002di_002c-Global-28

Also, for reproducibility, it might be desirable to pin netperf and 
netserver to a specific CPU or CPUs.  That would be with a global -T 
option: 
http://www.netperf.org/svn/netperf2/tags/netperf-2.5.0/doc/netperf.html#index-g_t_002dT_002c-Global-41

happy benchmarking,

rick jones
