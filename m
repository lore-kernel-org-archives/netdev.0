From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Fri, 01 Mar 2013 16:24:00 -0500 (EST)
Message-ID: <20130301.162400.1645765127882618751.davem@davemloft.net>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net,
	willemb@google.com, andi@firstfloor.org, hpa@zytor.com,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.jf.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Date: Wed, 27 Feb 2013 09:55:49 -0800

> This patchset adds the ability for the socket layer code to poll directly 
> on an Ethernet device's RX queue. This eliminates the cost of the interrupt
> and context switch and with proper tuning allows us to get very close
> to the HW latency.
> 
> This is a follow up to Jesse Brandeburg's Kernel Plumbers talk from last year
> http://www.linuxplumbersconf.org/2012/wp-content/uploads/2012/09/2012-lpc-Low-Latency-Sockets-slides-brandeburg.pdf

I just wanted to say that I like this work a lot.

It proves a lot of things I try to impress upon people who talk about
how RDMA is such a "must have" because the software stack can't
possibly give anything near HW latency.

Obviously such arguments are complete bullshit as is shown by these
changes.

This is exactly the kind of approach that makes sense rather than
trying to put entire TCP stacks in the network card firmware.

Thanks again for doing this work and I look forward to applying
this stuff once all the kinks are worked out.  The folks in the
Intel NIC group continue to impress me.
