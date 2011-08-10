From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v11 4/5] powerpc: Add flexcan device support for p1010rdb.
Date: Wed, 10 Aug 2011 12:01:51 -0500
Message-ID: <8E5FA886-038D-4DF4-8A54-DD60188A21A2@kernel.crashing.org>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>
	<1312993670-23999-5-git-send-email-holt@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312993670-23999-5-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
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


On Aug 10, 2011, at 11:27 AM, Robin Holt wrote:

> I added a simple clock source for the p1010rdb so the flexcan driver
> could determine a clock frequency.  The p1010 flexcan device only has
> an oscillator of system bus frequency divided by 2.
> 
> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> Cc: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> ---
> arch/powerpc/platforms/85xx/Kconfig    |    2 +
> arch/powerpc/platforms/85xx/Makefile   |    2 +
> arch/powerpc/platforms/85xx/clock.c    |   52 ++++++++++++++++++++++++++++++++
> arch/powerpc/platforms/85xx/p1010rdb.c |    8 +++++
> 4 files changed, 64 insertions(+), 0 deletions(-)
> create mode 100644 arch/powerpc/platforms/85xx/clock.c

I dont understand how mpc85xx_clk_functions() ends up being associated with the frequency the flexcan is running at.

This either seems to global or I'm missing something.

I still think the clk / freq info should be in the device tree and handled in the driver and NOT arch/powerpc platform code.

- k
