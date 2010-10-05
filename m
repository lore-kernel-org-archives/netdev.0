From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Tue, 05 Oct 2010 14:50:32 -0700 (PDT)
Message-ID: <20101005.145032.25126909.davem@davemloft.net>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
	<20101002112419.248437367@gulag1.americas.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: holt@sgi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101002112419.248437367@gulag1.americas.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robin Holt <holt@sgi.com>
Date: Sat, 02 Oct 2010 06:24:06 -0500

> Subject: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers to prevent integer overflows.
> 
> On a 16TB x86_64 machine, sysctl_tcp_mem[2], sysctl_udp_mem[2], and
> sysctl_sctp_mem[2] can integer overflow.  Set limit such that they are
> maximized without overflowing.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>

Robin please resubmit this with the SCTP bits included.
