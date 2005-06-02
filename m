From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 02 Jun 2005 14:40:03 -0700 (PDT)
Message-ID: <20050602.144003.35660495.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408>
	<20050602143126.7c302cfd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, hadi@cyberus.ca, jdmason@us.ibm.com,
        mitch.a.williams@intel.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050602143126.7c302cfd@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 2 Jun 2005 14:31:26 -0700

> For networking the problem is worse, the "right" choice depends on workload
> and relationship between components in the system. I can't see how you could
> ever expect a driver specific solution.   

I totally agree, even the mere concept of driver-centric decisions
in this area is pretty bogus.

> And for other workloads, and other systems (think about the Altix with
> long access latencies), your numbers will be wrong. Perhaps we need
> to quit trying for a perfect solution and just get a "good enough" one
> that works.

I don't understand why nobody is investigating doing this stuff
by generic measurements that the core kernel can perform.

The generic ->poll() runner code can say, wow it took N-usec to
process M packets, perhaps I should adjust the weight.

I haven't seen one concrete suggestion along those lines, yet that is
where the answer to this kind of stuff is.  Those kinds of solutions
are completely CPU, memory, I/O bus, network device, and workload
independant.
