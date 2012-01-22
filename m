From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/3] net: fix socket memcg build with !CONFIG_NET
Date: Sun, 22 Jan 2012 14:35:56 -0500 (EST)
Message-ID: <20120122.143556.1031473969223729555.davem@davemloft.net>
References: <1327071436-20763-2-git-send-email-glommer@parallels.com>
	<20120120.141446.136970067758991080.davem@davemloft.net>
	<4F1AC8F6.1060703@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F1AC8F6.1060703-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Sat, 21 Jan 2012 18:17:26 +0400

> I am not removing the static branch. This is just a macro, that
> expands to the static branch when the options are in place, and to 0
> if they are not.
> 
> if (0) { } is certainly be removed to the compiler, so the code is out
> anyway.

That's rather non-intuitive, oh well.

I'll apply this, but all of this stuff is an ifdef mess.
