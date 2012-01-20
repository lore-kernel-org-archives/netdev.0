From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/3] net: fix socket memcg build with !CONFIG_NET
Date: Fri, 20 Jan 2012 14:14:46 -0500 (EST)
Message-ID: <20120120.141446.136970067758991080.davem@davemloft.net>
References: <1327071436-20763-1-git-send-email-glommer@parallels.com>
	<1327071436-20763-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1327071436-20763-2-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Fri, 20 Jan 2012 18:57:14 +0400

> There is still a build bug with the sock memcg code, that triggers
> with !CONFIG_NET, that survived my series of randconfig builds.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Reported-by: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Why are you undoing the static branch optimization?  That was a one of
the things that made me agree to even putting this code in.

Find a way to fix this without removing the static branch.
