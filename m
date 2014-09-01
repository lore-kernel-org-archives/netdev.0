From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] packet.7: fix include file
Date: Mon, 01 Sep 2014 19:25:33 +0200
Message-ID: <5404AC0D.9050103@gmail.com>
References: <1409318406-5217-1-git-send-email-sdumitru@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sorin Dumitru <sorin-W1xJSxASJ7qhKNWrAYCRhA@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409318406-5217-1-git-send-email-sdumitru-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/29/2014 03:20 PM, Sorin Dumitru wrote:
> It looks like most of the socket options from this man pages
> are not defined in <netpacket/packet.h>. They are defined in
> <linux/if_packet.h> so we should include that one.

Hello Sorin,

It looks like <netpacket/packet.h> was based on some ancient
version of <linux/if_packet.h> that has not been updated.
Since linux/if_packet.h is under the "uapi" tree the
proposed patch seems the best fix. Thanks for sending it.
I've applied it.

Cheers,

Michael





> Signed-off-by: Sorin Dumitru <sdumitru-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>
> ---
>  man7/packet.7 | 14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/man7/packet.7 b/man7/packet.7
> index 57cd3ca..7b6f20d 100644
> --- a/man7/packet.7
> +++ b/man7/packet.7
> @@ -16,7 +16,7 @@ packet \- packet interface on device level
>  .nf
>  .B #include <sys/socket.h>
>  .br
> -.B #include <netpacket/packet.h>
> +.B #include <linux/if_packet.h>
>  .br
>  .B #include <net/ethernet.h>     /* the L2 protocols */
>  .sp
> @@ -535,18 +535,6 @@ is a new feature in Linux 2.2.
>  Earlier Linux versions supported only
>  .BR SOCK_PACKET .
>  .PP
> -The include file
> -.I <netpacket/packet.h>
> -is present since glibc 2.1.
> -Older systems need:
> -.sp
> -.in +4n
> -.nf
> -#include <asm/types.h>
> -#include <linux/if_packet.h>
> -#include <linux/if_ether.h>  /* The L2 protocols */
> -.fi
> -.in
>  .SH NOTES
>  For portable programs it is suggested to use
>  .B AF_PACKET
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
