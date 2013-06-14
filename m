From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency sockets follow ups
Date: Thu, 13 Jun 2013 17:43:39 -0700 (PDT)
Message-ID: <20130613.174339.1937633112098047039.davem@davemloft.net>
References: <20130613144613.4875.46858.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, alexr@mellanox.com,
	avnerb@mellanox.com, ork@mellanox.com,
	sockperf-dev@googlegroups.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130613144613.4875.46858.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Thu, 13 Jun 2013 17:46:13 +0300

> Here are three clean up patches, plus one that adds a socket option for LLS.
> 
> Patch 1 converts low latency sockets to sched_clock.
> Patch 2 removes the config menu for NET_LL_RX_POLL and defaults to y.
> Patch 3 converts sysctl_net_ll_poll into an unsigned int
> Patch 4 adds an SO_LL socket option to allow per-socket control of busy polling.
> 
> I will reply to this thread with a patch to sockperf that enables
> the socket option. (unchanged from v2)
> 
> Again, thanks to everyone for their comments.

Please respin with the overflow introduced by patch #3 corrected, everything
else looks fine to me.
