From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ROSE][NETROM] display neigh instead of address
Date: Mon, 03 Mar 2008 20:53:04 -0800 (PST)
Message-ID: <20080303.205304.225449154.davem@davemloft.net>
References: <20080211124251.GB3597@ff.dom.local>
	<20080211.212659.228544422.davem@davemloft.net>
	<47C88AEF.4050504@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
To: f6bvp@free.fr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <47C88AEF.4050504@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Date: Fri, 29 Feb 2008 23:45:03 +0100

> I submit the following patch against kernel 2.6.24.3 to replace
> labels "addr" in /proc/net/rose_neigh and /proc/net/nr_neigh
> by labels "neigh" for the display of neighbour numbers in the
> first columns.
> 
> This makes the reading of proc more consistent with the labels of
> /proc/net/rose_nodes and /proc/net/nr_nodes.
> Finding the callsign of a given node neighbour number becomes easier.

I'm not so sure there is much value to this.
"address", "neigh", it's all about the same.

Yes, it's inconsistent in various areas, but procfs
output is like a fixed API with userspace and we generally
cannot change it without potentially breaking userspace.
