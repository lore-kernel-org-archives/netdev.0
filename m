From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] net: fix sleeping while atomic problem in sock
 mem_cgroup.
Date: Fri, 16 Dec 2011 15:35:27 -0500 (EST)
Message-ID: <20111216.153527.844718089764883031.davem@davemloft.net>
References: <1324032720-13752-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1324032720-13752-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Fri, 16 Dec 2011 14:51:59 +0400

> We can't scan the proto_list to initialize sock cgroups, as it
> holds a rwlock, and we also want to keep the code generic enough to
> avoid calling the initialization functions of protocols directly,
> 
> Convert proto_list_lock into a mutex, so we can sleep and do the
> necessary allocations. This lock is seldom taken, so there shouldn't
> be any performance penalties associated with that
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
