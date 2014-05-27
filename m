From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V6 1/2] cpumask: Utility function to set n'th
 cpu - local cpu first
Date: Tue, 27 May 2014 15:24:14 -0400 (EDT)
Message-ID: <20140527.152414.1304343647733553805.davem@davemloft.net>
References: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
	<1401029247-15196-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, yuvala@mellanox.com,
	linux-kernel@vger.kernel.org
To: amirv@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401029247-15196-2-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amir Vadai <amirv@mellanox.com>
Date: Sun, 25 May 2014 17:47:26 +0300

> This function sets the n'th cpu - local cpu's first.
> For example: in a 16 cores server with even cpu's local, will get the
> following values:
> cpumask_set_cpu_local_first(0, numa, cpumask) => cpu 0 is set
> cpumask_set_cpu_local_first(1, numa, cpumask) => cpu 2 is set
> ...
> cpumask_set_cpu_local_first(7, numa, cpumask) => cpu 14 is set
> cpumask_set_cpu_local_first(8, numa, cpumask) => cpu 1 is set
> cpumask_set_cpu_local_first(9, numa, cpumask) => cpu 3 is set
> ...
> cpumask_set_cpu_local_first(15, numa, cpumask) => cpu 15 is set
> 
> Curently this function will be used by multi queue networking devices to
> calculate the irq affinity mask, such that as many local cpu's as
> possible will be utilized to handle the mq device irq's.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

I would like someone who cares about these cpumask interfaces to provide
a review.
