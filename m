From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Sat, 4 Mar 2006 15:18:42 -0800
Message-ID: <20060304231842.GA3103@kroah.com>
References: <20060303214036.11908.10499.stgit@gitlost.site> <20060303214236.11908.98881.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932087AbWCDXSr@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <20060303214236.11908.98881.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2006 at 01:42:36PM -0800, Chris Leech wrote:
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 13abfa2..b792048 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -262,6 +262,9 @@
>  #include <net/tcp.h>
>  #include <net/xfrm.h>
>  #include <net/ip.h>
> +#ifdef CONFIG_NET_DMA
> +#include <net/netdma.h>
> +#endif

#ifdef is not needed here (try not to put #ifdef in .c files.)  I think
a few of your other usages of #ifdef in this file can also be removed
with judicious use of inline functions in a .h file.

thanks,

greg k-h
