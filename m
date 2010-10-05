From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 5 Oct 2010 21:09:30 +0900
Message-ID: <002e01cb6486$2ed72cc0$66f8800a@maildom.okisemi.com>
References: <4C9C7C6F.1000003@dsn.okisemi.com>	<4CA4541F.5040804@grandegger.com>	<000401cb614f$c932c750$66f8800a@maildom.okisemi.com>	<4CA5D6D7.3010608@grandegger.com>
	<000401cb6477$25a0eba0$66f8800a@maildom.okisemi.com>
	<4CAB0732.3010400@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Hi Marc,

On Tuesday, October 05, 2010 8:08 PM, Marc Kleine-Budde wrote:
> If FIFO is working you might also think about NAPI.

I think NAPI isn't necessary for our CAN driver.
NAPI is for high-speed networking.
CAN is NOT high-speed.

In fact, some accepted CAN drivers don't have NAPI.

Thanks, Ohtake(OKISemi)
