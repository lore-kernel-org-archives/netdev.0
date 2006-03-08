From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch 0/4] net: percpufy frequently used vars on struct proto
Date: Tue, 7 Mar 2006 17:58:08 -0800
Message-ID: <20060308015808.GA9062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964872AbWCHB5b@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following patchset converts struct proto.memory_allocated to use batching
per-cpu counters, struct proto.sockets_allocated to use per-cpu counters and
changes the proto.inuse per-cpu variable to use alloc_percpu instead of the
NR_CPUS x cacheline size padding. 

We observed 5% improvement in apache bench requests per second with this 
patchset on a multi NIC 8 way IBM x460 box.

(This was posted earlier
http://marc.theaimsgroup.com/?l=linux-kernel&m=113830220408812&w=2 )

Can this go into -mm please?

Thanks,
Kiran
