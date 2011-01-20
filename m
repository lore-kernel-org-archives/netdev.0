From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
Date: Thu, 20 Jan 2011 13:35:52 +0200
Message-ID: <20110120113552.GB24349@shutemov.name>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
 <4D343658.1020205@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D343658.1020205-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 06:30:16AM -0600, Rob Landley wrote:
> On 01/14/2011 07:48 AM, Kirill A. Shutemov wrote:
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> > Only for client for now.
> 
> Ok, Google is being really unhelpful here.

It's better if you read the code. :)
> 
> What is rpc_pipefs for?  What uses it, and to do what exactly?  Is it
> used by nfs server code, or by the client code, or both?  Is it a way
> for userspace to talk to the kernel, or for the kernel to talk to
> itself?  Is it used at mount time, or during filesystem operation?

Ok, It try to answer. Please correct me, if I'm wrong.

rpc_pipefs is a userland/kernel interface (I don't see kernel-kernel
usecases, but it's possible, I guess).
There is client dir (nfs/clntX) in rpc_pipefs for every sunrpc client.
Both client and server (see fs/nfsd/nfs4callback.c) can create sunrpc
client. So we rpc_pipefs on both side.
rpc_pipefs uses not only on mount time. See old idmapper, for example.

> I'm interested in giving this patch series a much more thorough review,
> but I can't figure out what the subsystem it's modifying actually _is_.
> 
> (Maybe this is something to do with filesystems/nfs/rpc-cache.txt?)
> 
> Rob

-- 
 Kirill A. Shutemov
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
