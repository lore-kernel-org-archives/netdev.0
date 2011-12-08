From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
Date: Thu, 8 Dec 2011 15:46:48 -0500
Message-ID: <20111208204648.GB32505@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111207111716.17273.63010.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrote:
> This is another precursor patch set aimed to remove hard-coded "init_net"
> reference from SUNRPC sockaddr convertion and construction routines.

ACK--all look straightforward.  (Only complaint would be that this isn't
terribly interesting till we see how these are used.)

--b.


> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (4):
>       SUNRPC: use passed network namespace context in rpc_parse_scope_id()
>       SUNRPC: use passed network namespace context in rpc_pton6()
>       SUNRPC: use passed network namespace context in rpc_pton()
>       SUNRPC: use passed network namespace context in rpc_uaddr2sockaddr()
> 
> 
>  fs/nfs/dns_resolve.c        |    4 ++--
>  fs/nfs/nfs4filelayoutdev.c  |    2 +-
>  fs/nfs/nfs4namespace.c      |    2 +-
>  fs/nfs/super.c              |    4 ++--
>  fs/nfsd/nfs4state.c         |    2 +-
>  fs/nfsd/nfsctl.c            |    2 +-
>  include/linux/sunrpc/clnt.h |    4 ++--
>  net/sunrpc/addr.c           |   24 +++++++++++++-----------
>  net/sunrpc/rpcb_clnt.c      |    2 +-
>  net/sunrpc/svcauth_unix.c   |    2 +-
>  10 files changed, 25 insertions(+), 23 deletions(-)
> 
> -- 
> Signature
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
