From: Daniel Baluta <daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Thu, 12 Aug 2010 08:17:16 +0300
Message-ID: <AANLkTikvZQummcSeq8mrhYjatTvbtaNwL-6=GpTgTu5A@mail.gmail.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>
	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>, "Wang, Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org" <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>,
	"arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "Wang, Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB-QQHDSDV1ERZpB2pF5aRoyrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
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

>> 1. Is your code based on Intel's CAN EP80579 ([1]) ?
> No.

I want in the near future to write a Socket-CAN based driver for CAN EP80579.
As far as I've seen from your implementation there are a lot of
similarities between these
two drivers. Perhaps we can built a core part to both benefit from it.

>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
> Just take a look at kfifo.h. This structure has been changed. I remembered there was a spin_lock from kfifo previously. Currently it's been removed, good.
Inded, the kfifo infrastructure has suffered great reworkings in the
latest kernel versions, but this
is not an excuse to not use it.
> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to use this structure and APIs?
>
> Daniel,
>
> We're anxious to integrate those codes now. Perhaps it'll take us quite a long time to use kfifo. How about implementing it with the next version?

In my opinion, as it looks now your code will never be accepted by the
SocketCAN maintainers.

thanks,
Daniel.
