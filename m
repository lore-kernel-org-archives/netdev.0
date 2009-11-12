From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: Add missing debug flag for making USB CAN devices
Date: Thu, 12 Nov 2009 18:42:28 +0100
Message-ID: <4AFC4904.9040500@grandegger.com>
References: <4AFC2B6B.5090000@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4AFC2B6B.5090000-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Wolfgang Grandegger wrote:
> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> ---
>  drivers/net/can/usb/Makefile |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: net-next-2.6/drivers/net/can/usb/Makefile
> ===================================================================
> --- net-next-2.6.orig/drivers/net/can/usb/Makefile
> +++ net-next-2.6/drivers/net/can/usb/Makefile
> @@ -3,3 +3,5 @@
>  #
> 
>  obj-$(CONFIG_CAN_EMS_USB) += ems_usb.o
> +
> +ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG

Please drop this patch. I just realized that Oliver has already fixed
this issue in his "[PATCH net-2.6] can: Fix driver Kconfig structure"
here (see http://marc.info/?l=linux-netdev&m=125802571320568&w=2).

Sorry for the noise.

Wolfgang.
