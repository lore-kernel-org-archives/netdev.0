From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: RE: About bittiming calculation result
Date: Tue, 8 Feb 2011 10:09:48 +0900
Message-ID: <E2BAACFF191C4175854E6B2EB9135BE5@hacdom.okisemi.com>
References: <cover.1296818921.git.segoon@openwall.com><a6800dc8b0daed78256f98f52844cbbb48f4a76d.1296818921.git.segoon@openwall.com><20110204124233.GB334@e-circ.dyndns.org>
	<20110204.130649.112613896.davem@davemloft.net>
	<5009516791F146C49C73FAC57C437313@hacdom.okisemi.com>
	<4D4FDEF9.2030305@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "'Wolfgang Grandegger'" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D4FDEF9.2030305-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Monday, February 07, 2011 9:01 PM, Wolfgang Grandegger wrote
> 
> Well, only prop_seg+phase_seg=tseg1 is relevant and the 
> pch_can driver sets the allowed minimum "tseg1_min1" currently to 1:
> 
> static struct can_bittiming_const pch_can_bittiming_const = {
>         .name = KBUILD_MODNAME,
>         .tseg1_min = 1,
>         .tseg1_max = 16,
>         .tseg2_min = 1,
>         .tseg2_max = 8,
>         .sjw_max = 4,
>         .brp_min = 1,
>         .brp_max = 1024, /* 6bit + extended 4bit */
>         .brp_inc = 1,
> };
> 
> > seg1/seg2/sjw/prop_seg must be more than 1 ?
> 
> Then "tseg1_min" should be set to *2*.

Though some drivers accepted by upstream have parameter "tseg1_min" as 1,
Sould we release the patch like below ?
 -         .tseg1_min = 1,
+         .tseg1_min = 2,

Thanks,
-----------------------------------------
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
