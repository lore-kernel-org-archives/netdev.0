From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v6 06/20] can: EG20T PCH: Fix endianness issue
Date: Thu, 02 Dec 2010 13:17:28 -0800 (PST)
Message-ID: <20101202.131728.245392719.davem@davemloft.net>
References: <4CF47BAA.2090209@dsn.okisemi.com>
	<20101202.131551.179934201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101202.131551.179934201.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Thu, 02 Dec 2010 13:15:51 -0800 (PST)

> 
> This patch and the rest I cannot apply because they have
> dependencies upon patch #4 which I've stated is not
> implemented correctly.

Also please make sure that you add proper CONFIG_PM checks to your
driver in order to fix these warnings:

drivers/net/can/pch_can.c:249:13: warning: 'pch_can_set_int_custom' defined but not used
drivers/net/can/pch_can.c:260:13: warning: 'pch_can_get_int_enables' defined but not used
drivers/net/can/pch_can.c:363:12: warning: 'pch_can_get_rxtx_ir' defined but not used
drivers/net/can/pch_can.c:393:13: warning: 'pch_can_set_rx_buffer_link' defined but not used
drivers/net/can/pch_can.c:413:13: warning: 'pch_can_get_rx_buffer_link' defined but not used

Thanks.
d
