From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Sun, 24 Oct 2010 15:28:30 -0700 (PDT)
Message-ID: <20101024.152830.102557040.davem@davemloft.net>
References: <20101020120336.967805943@gulag1.americas.sgi.com>
	<20101020120345.436404838@gulag1.americas.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, vladislav.yasevich@hp.com, sri@us.ibm.com
To: holt@sgi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101020120345.436404838@gulag1.americas.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robin Holt <holt@sgi.com>
Date: Wed, 20 Oct 2010 07:03:37 -0500

> Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers to prevent integer overflows.
> 
> On a 16TB x86_64 machine, sysctl_tcp_mem[2], sysctl_udp_mem[2], and
> sysctl_sctp_mem[2] can integer overflow.  Set limit such that they are
> maximized without overflowing.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>

I'll queue this up for -stable, thanks Robin!
