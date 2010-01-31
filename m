From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] iplink_can: add support to set one-shot mode
Date: Sun, 31 Jan 2010 13:22:07 +0100
Message-ID: <4B6575EF.3030001@hartkopp.net>
References: <1261569778-23669-1-git-send-email-mkl@pengutronix.de>
	<4B4CE6D0.1030803@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B4CE6D0.1030803-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
> Marc Kleine-Budde wrote:
>> This patch adds the flag CAN_CTRLMODE_ONE_SHOT. It is used as mask
>> or flag in the "struct can_ctrlmode".
>>
>> It also adds to "ip" the option to set a CAN controller into the special
>> "one-shot" mode. In this mode, if supported by the CAN controller,
>> tries only once to deliver a CAN frame and aborts it if an error
>> (e.g.: arbitration lost) happens.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> 
> Could this patch be considered for iproute2 inclusion? The corresponding
> kernel patch has been accepted in the meantime.
> 
> Thanks,
> 
> Wolfgang.

Hello Stephen,

this patch sits in patchwork with the state "Changes Requested"

http://patchwork.ozlabs.org/patch/41660/

which is obviously wrong.

It would by nice if this change could get into iproute2 until 2.6.33 hits the
ground.

Thanks,
Oliver
