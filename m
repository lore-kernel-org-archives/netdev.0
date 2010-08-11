From: Daniel Baluta <daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 11 Aug 2010 13:37:26 +0300
Message-ID: <AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C61EDE5.4030505-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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

Hi,

2010/8/11 Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>:
> CAN driver of Topcliff PCH
>
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus.
> Topcliff PCH has CAN I/F. This driver enables CAN function.
>
> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

I have a few questions:

1. Is your code based on Intel's CAN EP80579 ([1]) ?
2. Why don't you use kernel existing kfifo infrastructure? ([2]).
3. Can you provide a pointer to Topcliff PCH CAN I/F datasheet ?

thanks,
Daniel.

[1] http://www.intel.com/design/intarch/ep80579/sw_tools.htm
[2] http://lxr.linux.no/#linux+v2.6.35/kernel/kfifo.c
