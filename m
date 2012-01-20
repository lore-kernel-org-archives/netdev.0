From: "bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v2 0/5] SUNRPC: make caches network namespace aware
Date: Fri, 20 Jan 2012 09:29:13 -0500
Message-ID: <20120120142913.GA9877@fieldses.org>
References: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
 <4F194B7F.4030002@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F194B7F.4030002-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2012 at 03:09:51PM +0400, Stanislav Kinsbursky wrote:
> I've tested NFSd under load - works like a charm (showmount reported right info).
> I've tested NFS mounts on host node - looks like all works fine.
> Also I've tested NFS mounts on host node and in container in the
> same time. There are some problems here. Most likely caused by
> user-space daemons, conflicting between themselves because of wrong
> initialization environment (like rpcbind registering problems, which
> I've raised in the list already).
> So looks like the patches suitable for devel branch.

OK, thanks:

	Acked-by: J. Bruce Fields <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

We should start testing the containerized nfsd side too, though--run
nfsd on a machine with multiple network namespaces, separate mountd's
and rpc.svcgssd's in each, figure out how to feed of them different
configurations, and check that requests to the different interfaces are
treated differently.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
