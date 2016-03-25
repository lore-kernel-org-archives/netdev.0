From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ip.7: Fix incorrect sockopt name
Date: Sat, 26 Mar 2016 08:36:15 +1300
Message-ID: <56F5932F.6000809@gmail.com>
References: <1458592124-6208-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radek Pazdera <rpazdera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Benjamin Poirier <bpoirier-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458592124-6208-1-git-send-email-bpoirier-IBi9RG/b67k@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Benjamin,

On 03/22/2016 09:28 AM, Benjamin Poirier wrote:
> "IP_LEAVE_GROUP" does not exist. It was perhaps a confusion with
> MCAST_LEAVE_GROUP. Change the text to IP_DROP_MEMBERSHIP which has the same
> function as MCAST_LEAVE_GROUP and is documented in the ip.7 man page.
> 
> Reference:
> Linux kernel net/ipv4/ip_sockglue.c do_ip_setsockopt()

Thanks! Applied.

Cheers,

Michael


> Cc: Radek Pazdera <rpazdera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Benjamin Poirier <bpoirier-IBi9RG/b67k@public.gmane.org>
> ---
>  man7/ip.7 | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man7/ip.7 b/man7/ip.7
> index 3905573..37e2c86 100644
> --- a/man7/ip.7
> +++ b/man7/ip.7
> @@ -376,7 +376,7 @@ a given multicast group that come from a given source.
>  If the application has subscribed to multiple sources within
>  the same group, data from the remaining sources will still be delivered.
>  To stop receiving data from all sources at once, use
> -.BR IP_LEAVE_GROUP .
> +.BR IP_DROP_MEMBERSHIP .
>  .IP
>  Argument is an
>  .I ip_mreq_source
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
