From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [2.6 PATCH] ipvs - two additional minor patches
Date: Mon, 6 Oct 2003 19:54:49 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310061954030.2820-100000@penguin.linux-vs.org>
References: <20031005075058.70532394.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rusty@rustcorp.com.au, <ja@ssi.bg>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031005075058.70532394.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sun, 5 Oct 2003, David S. Miller wrote:

> On Sun, 5 Oct 2003 20:41:34 +0800 (CST)
> Wensong Zhang <wensong@linux-vs.org> wrote:
> 
> > The ip_vs_procfs.patch is to the #ifdef CONFIG_PROC_FS macro for proc file 
> > creation/destruction.
> 
> I'm not applying this patch, it is completely not needed.
> 
> linux/proc_fs.h defines two versions of these interfaces based
> upon whether CONFIG_PROC_FS is defined or not, when it is not
> defined calling the interfaces is a nop.
> 
> In this way we don't have to litter the sources with tons of
> ifdefs like your patch was adding.
> 

I see. Sorry for the trouble.

Regards,

Wensong
