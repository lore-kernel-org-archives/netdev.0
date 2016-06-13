From: Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/3] infiniband: rxe: add UDP_TUNNEL dependency
Date: Mon, 13 Jun 2016 18:28:12 +0300
Message-ID: <CAG9sBKNJAb+7RXa4RFmmWExcy_NjsZRbFp11m0AWJLqbTd03DA@mail.gmail.com>
References: <1465822509-4167617-1-git-send-email-arnd@arndb.de> <1465822509-4167617-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Kamal Heib <kamalh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465822509-4167617-2-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

thanks. will be applied to next series

On Mon, Jun 13, 2016 at 3:54 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> The newly added rxe driver links against the UDP tunneling code,
> which causes build errors when CONFIG_UDP_TUNNEL is disabled:
>
> ERROR: "setup_udp_tunnel_sock" [drivers/infiniband/hw/rxe/ib_rxe.ko] undefined!
> ERROR: "udp_tunnel_sock_release" [drivers/infiniband/hw/rxe/ib_rxe.ko] undefined!
> ERROR: "udp_sock_create4" [drivers/infiniband/hw/rxe/ib_rxe.ko] undefined!
>
> This adds a Kconfig dependency to prevent the invalid configuration.
>
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> ---
>  drivers/infiniband/hw/rxe/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/infiniband/hw/rxe/Kconfig b/drivers/infiniband/hw/rxe/Kconfig
> index 649b7be11eb8..a199d0df31d0 100644
> --- a/drivers/infiniband/hw/rxe/Kconfig
> +++ b/drivers/infiniband/hw/rxe/Kconfig
> @@ -1,6 +1,7 @@
>  config INFINIBAND_RXE
>         tristate "Software RDMA over Ethernet (RoCE) driver"
>         depends on INET && PCI && INFINIBAND
> +       depends on NET_UDP_TUNNEL
>         ---help---
>         This driver implements the InfiniBand RDMA transport over
>         the Linux network stack. It enables a system with a
> --
> 2.7.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
