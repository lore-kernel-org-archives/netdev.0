From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] MAINTAINER: Correct CAN Maintainer responsibilities and
	paths
Date: Sat, 06 Mar 2010 18:48:01 +0100
Message-ID: <4B929551.3000901@grandegger.com>
References: <4B929F96.1030402@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B929F96.1030402-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Update the CAN Maintainer responsibilities and add source paths.
> Additional the SocketCAN core ML is not subscribers-only anymore.
> 
> Signed-off-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> 
> ---
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 34f52a1..9ee1f78 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1372,20 +1372,28 @@ F:	arch/x86/include/asm/calgary.h
>  F:	arch/x86/include/asm/tce.h
> 
>  CAN NETWORK LAYER
> -M:	Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
> +M:	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
>  M:	Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
> -L:	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org (subscribers-only)
> +M:	Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
> +L:	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
>  W:	http://developer.berlios.de/projects/socketcan/
>  S:	Maintained
> -F:	drivers/net/can/
> -F:	include/linux/can/
> +F:	net/can/
>  F:	include/linux/can.h
> +F:	include/linux/can/core.h
> +F:	include/linux/can/bcm.h
> +F:	include/linux/can/raw.h
> 
>  CAN NETWORK DRIVERS
>  M:	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> -L:	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org (subscribers-only)
> +L:	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
>  W:	http://developer.berlios.de/projects/socketcan/
>  S:	Maintained
> +F:	drivers/net/can/
> +F:	include/linux/can/dev.h
> +F:	include/linux/can/error.h
> +F:	include/linux/can/netlink.h
> +F:	include/linux/can/platform/
> 
>  CELL BROADBAND ENGINE ARCHITECTURE
>  M:	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> 

Looks good ==>

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
