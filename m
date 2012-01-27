From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 15:22:46 +0100
Message-ID: <20120127142246.GA22318@elte.hu>
References: <20120127124641.GA30819@elte.hu>
 <4F229D5C.4040300@parallels.com>
 <20120127125645.GA28131@elte.hu>
 <20120127141754.GA30202@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120127141754.GA30202@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> ok, i've bisected it, and the bad commit is:
> 
> 3dc43e3e4d0b52197d3205214fe8f162f9e0c334 is the first bad commit
> commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334
> Author: Glauber Costa <glommer@parallels.com>
> Date:   Sun Dec 11 21:47:05 2011 +0000
> 
>     per-netns ipv4 sysctl_tcp_mem

Might be related to this detail in the .config:

 # CONFIG_PROC_SYSCTL is not set

So former tcp_init() code does not get run?

Thanks,

	Ingo
