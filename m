From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] include/uapi/linux/sockios.h: mark SIOCRTMSG unused
Date: Wed, 30 Dec 2015 11:56:35 +0100
Message-ID: <5683B863.9010506@gmail.com>
References: <1451427722-2672-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451427722-2672-1-git-send-email-xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Heinrich,

On 12/29/2015 11:22 PM, Heinrich Schuchardt wrote:
> IOCTL SIOCRTMSG does nothing but return EINVAL.
> 
> So comment it as unused.

Can you say something about how you confirmed this?
It's not immediately obvious from the code.

Cheers,

Michael


> Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
> ---
>  include/uapi/linux/sockios.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
> index e888b1a..8e7890b 100644
> --- a/include/uapi/linux/sockios.h
> +++ b/include/uapi/linux/sockios.h
> @@ -27,7 +27,7 @@
>  /* Routing table calls. */
>  #define SIOCADDRT	0x890B		/* add routing table entry	*/
>  #define SIOCDELRT	0x890C		/* delete routing table entry	*/
> -#define SIOCRTMSG	0x890D		/* call to routing system	*/
> +#define SIOCRTMSG	0x890D		/* unused			*/
>  
>  /* Socket configuration controls. */
>  #define SIOCGIFNAME	0x8910		/* get iface name		*/
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
