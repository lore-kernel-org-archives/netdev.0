From: Rick Jones <rick.jones2-ZPxbGqLxI0U@public.gmane.org>
Subject: Re: [patch] netlink.7: srcfix Change buffer size in example code
 about reading netlink message.
Date: Mon, 14 Nov 2016 14:36:28 -0800
Message-ID: <7f6d8b0b-6f29-37af-9b25-47a2e78a31fd@hpe.com>
References: <e9409957290af5249750afa0f10de3a6@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dwilder <dwilder-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <e9409957290af5249750afa0f10de3a6-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Lets change the example so others don't propagate the problem further.
>
> Signed-off-by David Wilder <dwilder-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
> --- man7/netlink.7.orig 2016-11-14 13:30:36.522101156 -0800
> +++ man7/netlink.7      2016-11-14 13:30:51.002086354 -0800
> @@ -511,7 +511,7 @@
>  .in +4n
>  .nf
>  int len;
> -char buf[4096];
> +char buf[8192];

Since there doesn't seem to be a define one could use in the user space 
linux/netlink.h (?), but there are comments in the example code in the 
manpage, how about also including a brief comment to the effect that 
using 8192 bytes will avoid message truncation problems on platforms 
with a large PAGE_SIZE?

/* avoid msg truncation on > 4096 byte PAGE_SIZE platforms */

or something like that.

rick jones
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
