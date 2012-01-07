From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: fix sock_clone reference mismatch with tcp
 memcontrol
Date: Sat, 07 Jan 2012 10:17:02 -0800 (PST)
Message-ID: <20120107.101702.971636020211532236.davem@davemloft.net>
References: <1325830599-11857-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1325830599-11857-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Fri,  6 Jan 2012 10:16:39 +0400

> Sockets can also be created through sock_clone. Because it copies
> all data in the sock structure, it also copies the memcg-related pointer,
> and all should be fine. However, since we now use reference counts in
> socket creation, we are left with some sockets that have no reference
> counts. It matters when we destroy them, since it leads to a mismatch.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Applied, thanks.
