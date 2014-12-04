From: Masahiro Yamada <yamada.m-NAum8xwdG0+S7A1Ibl2khg@public.gmane.org>
Subject: Re: [PATCH] uapi: fix to export linux/vm_sockets.h
Date: Thu, 04 Dec 2014 17:15:17 +0900
Message-ID: <20141204171516.E206.AA925319@jp.panasonic.com>
References: <1417396577-32499-1-git-send-email-yamada.m@jp.panasonic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Piotr Krol <piotr.krol-zILERgsGILsAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Sakari Ailus <sakari.ailus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417396577-32499-1-git-send-email-yamada.m-NAum8xwdG0+S7A1Ibl2khg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi.

Is there a chance to fix this by the Linux 3.18 release?

Thanks.




On Mon,  1 Dec 2014 10:16:17 +0900
Masahiro Yamada <yamada.m-NAum8xwdG0+S7A1Ibl2khg@public.gmane.org> wrote:

> A typo "header=y" was introduced by commit 7071cf7fc435
> (uapi: add missing network related headers to kbuild).
> 
> Signed-off-by: Masahiro Yamada <yamada.m-NAum8xwdG0+S7A1Ibl2khg@public.gmane.org>
> Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
> ---
> 
>  include/uapi/linux/Kbuild | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
> index 4c94f31..8523f9b 100644
> --- a/include/uapi/linux/Kbuild
> +++ b/include/uapi/linux/Kbuild
> @@ -427,7 +427,7 @@ header-y += virtio_net.h
>  header-y += virtio_pci.h
>  header-y += virtio_ring.h
>  header-y += virtio_rng.h
> -header=y += vm_sockets.h
> +header-y += vm_sockets.h
>  header-y += vt.h
>  header-y += wait.h
>  header-y += wanrouter.h
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
