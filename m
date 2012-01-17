From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] move sock_update_memcg outside of CONFIG_INET
Date: Tue, 17 Jan 2012 10:16:22 -0500 (EST)
Message-ID: <20120117.101622.533172793237678130.davem@davemloft.net>
References: <1326701079-10331-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1326701079-10331-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Mon, 16 Jan 2012 12:04:39 +0400

> Although only used currently for tcp sockets, this function
> is now used in common sock code (for sock_clone())
> 
> Commit 475f1b52645a29936b9df1d8fcd45f7e56bd4a9f moved the
> declaration of sock_update_clone() to inside sock.c, but
> this only fixes the problem when CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> is also not defined.
> 
> This patch here is verified to fix both problems, although
> reverting the previous one is not necessary.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Applied, but with a fixed subject line, you must always prefix your
subject line with the subsystem your change is being made to.  In
this case simply "net: " would have been sufficient, so that's what
I added.
