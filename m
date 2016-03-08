From: David Miller <davem@davemloft.net>
Subject: Re: Tool for sampling /proc/net/softnet_stat statistics
Date: Tue, 08 Mar 2016 14:47:59 -0500 (EST)
Message-ID: <20160308.144759.2020954787254128202.davem@davemloft.net>
References: <20160307163607.1da5f17e@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	linux-kernel@vger.kernel.org
To: jbrouer@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307163607.1da5f17e@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Date: Mon, 7 Mar 2016 16:36:07 +0100

> I lack of better, I coded up my own tool softnet_stat.pl here:
>  https://github.com/netoptimizer/network-testing/blob/master/bin/softnet_stat.pl
> 
> The output format/columns in /proc/net/softnet_stat is undocumented,
> plus values are printed in hex.  E.g. to decode the columns you need to
> read kernel function kernel softnet_seq_show() in
> kernel/net/core/net-procfs.c.
> 
> To make things easier I wrote this small perl script for get
> so human readable statistics from /proc/net/softnet_stat.

Good stuff!
