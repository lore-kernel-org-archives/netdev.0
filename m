From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 6 Oct 2010 12:07:15 +0900
Message-ID: <000b01cb6503$962bc7f0$66f8800a@maildom.okisemi.com>
References: <000401cb6477$25a0eba0$66f8800a@maildom.okisemi.com><4CAB0732.3010400@pengutronix.de><002e01cb6486$2ed72cc0$66f8800a@maildom.okisemi.com>
	<20101005.114506.184852374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

Hi David,

On Wednesday, October 06, 2010 3:45 AM, David Miller wrote,
> We encourage all new drivers that can use NAPI to do so, just because
> recent driver submissions do not do this doesn't mean we should
> continue such a mistake ;-)

I understand NAPI's merit.
But, since we have already implemented without NAPI.
If possible, we don't want to use NAPI.

Does your mail mean, for accepting upstream, NAPI is essential for CAN driver ?
If essential, we will just do.

Thanks, Ohtake(OKISemi)
----- Original Message ----- 
From: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Cc: <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>; <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>; <chripell-VaTbYqLCNhc@public.gmane.org>; <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>;
<morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>; <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>;
<yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>;
<qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sent: Wednesday, October 06, 2010 3:45 AM
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35


> From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> Date: Tue, 5 Oct 2010 21:09:30 +0900
>
> > On Tuesday, October 05, 2010 8:08 PM, Marc Kleine-Budde wrote:
> >> If FIFO is working you might also think about NAPI.
> >
> > I think NAPI isn't necessary for our CAN driver.
> > NAPI is for high-speed networking.
> > CAN is NOT high-speed.
> >
> > In fact, some accepted CAN drivers don't have NAPI.
>
> NAPI is not just for performance concerns.
>
> It greatly simplifies the locking since all packet processing paths
> run only in software interrupt context, never in hardware interrupt
> context.
>
> We encourage all new drivers that can use NAPI to do so, just because
> recent driver submissions do not do this doesn't mean we should
> continue such a mistake ;-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
