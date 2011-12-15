From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] Explicitly call tcp creation and init from
 memcontrol.c
Date: Thu, 15 Dec 2011 17:44:11 -0500 (EST)
Message-ID: <20111215.174411.213210944798851570.davem@davemloft.net>
References: <1323941672-14324-3-git-send-email-glommer@parallels.com>
	<20111215.120028.532844419499092747.davem@davemloft.net>
	<4EEA6288.1080405@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EEA6288.1080405-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Fri, 16 Dec 2011 01:11:36 +0400

> How about the following patch then ? I am keeping protocols that has
> the cgroup stuff on in a separate list, that can be protected by a
> mutex. Therefore we can allocate without going into troubles.

This is a significantly better approach, please test and submit this
patch formally.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
