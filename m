From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet device polling
Date: Thu, 23 May 2013 14:06:51 +0300
Message-ID: <519DF84B.10401@linux.intel.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com> <519B632F.7040202@mellanox.com> <519B68A4.3010406@linux.intel.com> <519B7355.9090303@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Alex Rosenbaum <alexr@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519B7355.9090303@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/05/2013 16:15, Alex Rosenbaum wrote:
> On 5/21/2013 3:29 PM, Eliezer Tamir wrote:
>> What benchmarks are you using to test poll/select/epoll?
> for epoll/select latency tests we are using sockperf as performance
> latency tool: https://code.google.com/p/sockperf/
> It is a client-server based tool and it supported ping-pong, throughput,
> and under-load test type.
> For epoll, you will need to define a 'feedfile' ("-f filepathname")
> which has a list of TCP and/or UDP socket and defined your IO mux type
> ("-F epoll").

Thank you!
This is very helpful.

With sockperf i can directly observe how poll/select/epoll are behaving.
I can see some improvement in all of them but clearly more work is 
needed here.

-Eliezer
