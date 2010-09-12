From: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] enable getsockopt() for IP_NODEFRAG
Date: Sun, 12 Sep 2010 23:52:30 +0200
Message-ID: <20100912215230.GA2091@jolsa.Belkin>
References: <4C8B2130.7030605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C8B2130.7030605-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 11, 2010 at 08:26:56AM +0200, Michael Kerrisk wrote:
> Hello Jiri
> 
> While integrating your man-pages patch for IP_NODEFRAG, I noticed 
> that this option is settable by setsockopt(), but not gettable by 
> getsockopt(). I suppose this is not intended. The (untested, 
> trivial) patch below adds getsockopt() support.
> 
> The patch is against 2.6.36-rc3.
> 
> Cheers,
> 
> Michael
> 
> PS I've just configured Thunderbird on this machine, hopefully the 
> patch is not mangled. Please let me know if there are problems.
hi,

applied ok, compiled ok ;) thanks

Acked-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

> 
> Signed-off-by: Michael kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> --- net/ipv4/ip_sockglue.c.orig	2010-09-11 07:25:58.000000000 +0200
> +++ net/ipv4/ip_sockglue.c	2010-09-11 07:43:43.000000000 +0200
> @@ -1129,6 +1129,9 @@ static int do_ip_getsockopt(struct sock
>  	case IP_HDRINCL:
>  		val = inet->hdrincl;
>  		break;
> +	case IP_NODEFRAG:
> +		val = inet->nodefrag;
> +		break;
>  	case IP_MTU_DISCOVER:
>  		val = inet->pmtudisc;
>  		break;
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Watch my Linux system programming book progress towards publication!
> http://blog.man7.org/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
