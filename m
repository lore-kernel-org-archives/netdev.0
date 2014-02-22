From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] socket: Add SO_RXQ_OVFL documentation
Date: Sat, 22 Feb 2014 10:36:08 +0100
Message-ID: <53086F88.5040209@gmail.com>
References: <1390911877-5984-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390911877-5984-1-git-send-email-nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/28/2014 01:24 PM, Neil Horman wrote:
> Add documentation for the SO_RXQ_OVFL socket option
> 
> Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> CC: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> CC: andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org
> CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  man7/socket.7 | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/man7/socket.7 b/man7/socket.7
> index 6b229dd..aa0aad9 100644
> --- a/man7/socket.7
> +++ b/man7/socket.7
> @@ -663,6 +663,11 @@ with a specific port then it is not possible
>  to bind to this port for any local address.
>  Argument is an integer boolean flag.
>  .TP
> +.B SO_RXQ_OVFL
> +Indicates that an unsigned 32 bit value ancilliary msg (cmsg) should be attached
> +to recieved skbs indicating the number of packets dropped by the socket between
> +the last recieved packet and this received packet
> +.TP
>  .B SO_SNDBUF
>  Sets or gets the maximum socket send buffer in bytes.
>  The kernel doubles this value (to allow space for bookkeeping overhead)

Thanks, Neil. Applied.

Cheers,

Michael




-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
