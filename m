From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Mon, 15 Nov 2010 17:41:47 +0900
Message-ID: <00b801cb84a0$f0f9af00$66f8800a@maildom.okisemi.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de> <4CCAF517.2000409@pengutronix.de>
	<001701cb7a78$99e1fe20$66f8800a@maildom.okisemi.com>
	<4CCFEFE9.1020806@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"Wolfram Sang" <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On Tuesday, November 02, 2010 8:03 PM, Marc Kleine-Budde wrote:

> BTW: Does the Intel chip support x64? If so, have you tested the driver
> on a 64 bit kernel.
No, x64 is not supported.

Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.

----- Original Message ----- 
From: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Cc: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>; "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>; "Wolfram Sang"
<w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>; "Christian Pellegrin" <chripell-VaTbYqLCNhc@public.gmane.org>; "Barry Song" <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>; "Samuel Ortiz"
<sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>; <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>; <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; "LKML"
<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>;
<yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>; <kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sent: Tuesday, November 02, 2010 8:03 PM
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build warnings
