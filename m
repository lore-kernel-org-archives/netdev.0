From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: can: About Socket CAN with MSI issue
Date: Wed, 27 Oct 2010 13:29:15 +0900
Message-ID: <002801cb758f$876aaf00$66f8800a@maildom.okisemi.com>
References: <4CC61B1B.3090602@dsn.okisemi.com>
	<20101026.105206.15244527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>, <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <chripell-VaTbYqLCNhc@public.gmane.org>, <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
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

We have faced issue when our CAN diriver whose MSI is enabled, after installing the driver,
once remove the driver and install the driver again,
As a result, interupt handler of the driver is not called again.

Do you have any information or suggestion about the above issue?

As to the our latest CAN driver,
please refer to followoing patch posted by me.
[PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build warnings

Thanks, Tomoya(OKI SEMICONDUCTOR CO., LTD.)
