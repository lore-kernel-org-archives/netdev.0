From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified
 root
Date: Fri, 10 Aug 2012 20:28:18 +0100
Message-ID: <20120810202818.06236f46@pyramind.ukuu.org.uk>
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
	<50254FA6.3060806@zytor.com>
	<20120810192628.79a34d28@pyramind.ukuu.org.uk>
	<20120810191149.GA17985@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120810191149.GA17985-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Aug 2012 15:11:50 -0400
"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:

> On Fri, Aug 10, 2012 at 07:26:28PM +0100, Alan Cox wrote:
> > > On that whole subject...
> > > 
> > > Do we need a Unix domain socket equivalent to openat()?
> > 
> > I don't think so. The name is just a file system indexing trick, it's not
> > really the socket proper. It's little more than "ascii string with
> > permissions attached"
> 
> That's overstating the case.  As I understand it the address is resolved
> by a pathname lookup like any other--it can follow symlinks, is relative
> to the current working directory and filesystem namespace, etc. 

Explicitly for Linux yes - this is not generally true of the AF_UNIX
socket domain and even the permissions aspect isn't guaranteed to be
supported on some BSD environments !

The name is however just a proxy for the socket itself. You don't even
get a device node in the usual sense or the same inode in the file system
space.

Alan
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
