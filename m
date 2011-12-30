From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
Date: Fri, 30 Dec 2011 17:55:05 -0500
Message-ID: <1325285705.10984.4.camel@lade.trondhjem.org>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111129090754.20730.64567.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-29 at 13:10 +0300, Stanislav Kinsbursky wrote: 
> This patch set was created in context of clone of git
> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
> tag: v3.1
> 
> This patch set depends on previous patch sets titled:
> 1) "SUNRPC: initial part of making pipefs work in net ns"
> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
> 3) "SUNRPC: make RPC clients use network-namespace-aware PipeFS routines"
> 4) "NFS: create clients and IDMAP pipes per network namespace"
> 
> This patch set is the final part of making SUNRPC PipeFS and it's users work in
> network namespace context.
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (5):
>       NFS: handle blocklayout pipe PipeFS dentry by network namespace aware routines
>       NFS: blocklayout pipe creation per network namespace context introduced
>       NFS: blocklayout PipeFS notifier introduced
>       NFS: remove RPC PipeFS mount point reference from blocklayout routines
>       SUNRPC: kernel PipeFS mount point creation routines removed
> 
> 
>  fs/nfs/blocklayout/blocklayout.c    |  154 ++++++++++++++++++++++++++++-------
>  fs/nfs/blocklayout/blocklayout.h    |    3 -
>  fs/nfs/blocklayout/blocklayoutdev.c |    5 +
>  fs/nfs/blocklayout/blocklayoutdm.c  |    7 +-
>  fs/nfs/inode.c                      |    1 
>  fs/nfs/netns.h                      |    1 
>  include/linux/sunrpc/rpc_pipe_fs.h  |    2 
>  net/sunrpc/rpc_pipe.c               |   21 -----
>  8 files changed, 137 insertions(+), 57 deletions(-)


These patches need rebasing in order to apply on top of 3.2-rc7...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
