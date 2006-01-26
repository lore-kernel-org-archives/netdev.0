From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch 0/4] net: Percpufy frequently used variables on struct proto
Date: Thu, 26 Jan 2006 10:56:49 -0800
Message-ID: <20060126185649.GB3651@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	shai@scalex86.org, netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964795AbWAZS4p@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches change struct proto.memory_allocated,
proto.sockets_allocated to use per-cpu counters. This patchset also switches
the proto.inuse percpu varible to use alloc_percpu, instead of NR_CPUS *
cacheline size padding.

We saw 5 % improvement in apache bench requests per second with this
patchset, on a multi nic 8 way 3.3 GHZ IBM x460 Xeon server.  

Patches follow.

Thanks,
Kiran
