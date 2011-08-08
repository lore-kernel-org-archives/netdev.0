From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 20:37:37 +0200
Message-ID: <4E402CF1.1040300@grandegger.com>
References: <20110808135630.GU4926@sgi.com>
	<4E3FEFBB.9050103@grandegger.com>	<20110808142153.GW4926@sgi.com>
	<4E3FF4B8.2010603@grandegger.com>	<20110808144424.GY4926@sgi.com>
	<4E3FF9EA.6030601@grandegger.com>	<4E3FFD5B.7080000@pengutronix.de>
	<4E4001E1.3030508@grandegger.com>	<20110808155540.GD4926@sgi.com>
	<4E4008BA.6030303@grandegger.com> <20110808160810.GF4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808160810.GF4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/08/2011 06:08 PM, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 06:03:06PM +0200, Wolfgang Grandegger wrote:
...
> So we would stay with the clk_* functions.  I assume clk_get() would
> return NULL, clk_get_rate() would just return fsl_get_sys_freq() and
> the other functions would do nothing.  Doesn't this really polute what
> clk_* functions are supposed to do?  Aren't we making flexcan dictate
> a different behavior for powerpc than for the arm (and possibly other)
> architectures?

Well, I see it as one way to provide compatibility with the ARM port. If
the PowerPC people don't like it, we can switch to something else,
whatever they suggest.

Wolfgang.
