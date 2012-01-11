From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
Date: Wed, 11 Jan 2012 12:46:03 -0500
Message-ID: <1326303963.19024.1.camel@lade.trondhjem.org>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
			 <1325285705.10984.4.camel@lade.trondhjem.org>
		 <1325797111.11084.22.camel@lade.trondhjem.org>
		 <4F0C35F3.7060508@parallels.com>
	 <1326299003.17212.7.camel@lade.trondhjem.org>
	 <4F0DC582.6030805@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F0DC582.6030805-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-01-11 at 21:23 +0400, Stanislav Kinsbursky wrote: 
> I've sent rebased "v2" of the patch set, contains updated patch "SUNRPC: handle 
> RPC client pipefs dentries by network namespace aware routine", which, I 
> believe, fixes oops, spotted by Bryan (it was caused by excessive call of 
> rpc_put_mount() on PipeFS dentries unlink).
> So, if I'm not mistaken here, there's no need in implementing of dummy versions 
> of rpc_pipefs_notifier_(un)register() or any other dummy stuff.

OK. Fair enough. We'll give it some testing to make sure that we don't
hit it again...

> BTW, it looks like that in last 2 days I've sent all updates to the issues you 
> pointed out. If not, please, ping me once more.

I'm in the process of reviewing it right now.

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
