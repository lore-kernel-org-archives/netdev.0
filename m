From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Tue, 28 Jan 2014 23:52:14 -0800 (PST)
Message-ID: <20140128.235214.881810600024309551.davem@davemloft.net>
References: <20140128205756.074448668@goodmis.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com, stable@vger.kernel.org,
	williams@redhat.com, lclaudio@uudg.org, jkacur@redhat.com
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140128205756.074448668@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 28 Jan 2014 15:57:56 -0500

> At Red Hat we base our real-time kernel off of 3.10.27 and do lots of
> stress testing on that kernel. This has discovered some bugs that we
> can hit with the vanilla 3.10.27 kernel (no -rt patches applied).
> 
> I sent out a bug fix that can cause a crash with the current 3.10.27
> when you add and then remove the sit module. That patch is obsoleted by
> these patches, as that patch was not enough.
> 
> A previous patch that was backported:
> 
>   Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5
>   sit: allow to use rtnl ops on fb tunnel
> 
> Had a depenency on commit 5e6700b3bf98 ("sit: add support of x-netns")
> which was not backported. The dependency was only on part of that
> commit which is what I backported.
> 
> The other upstream commit 9434266f2c645d4fcf62a03a8e36ad8075e37943
> sit: fix use after free of fb_tunnel_dev
> 
> fixes another bug we encountered, it also fixes the 3.10.27 bug
> where removing the sit module cause the crash. This is the patch
> that obsoletes my previous patch.

Greg, these have my blessing, please apply these to 3.10 -stable,
thanks a lot!
