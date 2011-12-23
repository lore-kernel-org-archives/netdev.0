From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] Partial revert "Basic kernel memory functionality
 for the Memory Controller"
Date: Thu, 22 Dec 2011 22:39:23 -0500 (EST)
Message-ID: <20111222.223923.800285938031564380.davem@davemloft.net>
References: <1324551747-5925-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org,
	gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1324551747-5925-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Thu, 22 Dec 2011 15:02:27 +0400

> This reverts commit e5671dfae59b165e2adfd4dfbdeab11ac8db5bda.
> 
> After a follow up discussion with Michal, it was agreed it would
> be better to leave the kmem controller with just the tcp files,
> deferring the behavior of the other general memory.kmem.* files
> for a later time, when more caches are controlled. This is because
> generic kmem files are not used by tcp accounting and it is
> not clear how other slab caches would fit into the scheme.
> 
> We are reverting the original commit so we can track the reference.
> Part of the patch is kept, because it was used by the later tcp
> code. Conflicts are shown in the bottom. init/Kconfig is removed from
> the revert entirely.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Applied.
