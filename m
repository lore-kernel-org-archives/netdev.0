From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipvs - two additional minor patches
Date: Sun, 5 Oct 2003 07:50:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005075058.70532394.davem@redhat.com>
References: <Pine.LNX.4.44.0310052040210.1942-300000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, ja@ssi.bg, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0310052040210.1942-300000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Oct 2003 20:41:34 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> The ip_vs_procfs.patch is to the #ifdef CONFIG_PROC_FS macro for proc file 
> creation/destruction.

I'm not applying this patch, it is completely not needed.

linux/proc_fs.h defines two versions of these interfaces based
upon whether CONFIG_PROC_FS is defined or not, when it is not
defined calling the interfaces is a nop.

In this way we don't have to litter the sources with tons of
ifdefs like your patch was adding.
