From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [RFC 0/4] [flexcan] Add support for powerpc (freescale p1010) -V6
Date: Sat,  6 Aug 2011 09:34:25 -0500
Message-ID: <1312641270-6018-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

Marc, Wolfgang or U Bhaskar,

This patch set should have all your comments included.

I did implement a very simple clock source in the p1010rdb.c file, which,
unfortunately, your tree will not have so please do not apply the last
patch in the series.  That will need to go to the powerpc folks and
follow the p1010rdb patch from freescale.

Could you please apply the first three patches to a test branch, compile
and test them on an arm based system?  I would like to at least feel
comfortable that I have not broken anything there.

I have tested the full set on a p1010rdb with an external PSOC based
can communicator.  That PSOC code has a bunch of erroneous can comms it
can generate, but I do not know how the developer of that code injects
those errors.  As a result, no error handling from the can input has been
tested.  I have tested both flexcan interfaces on the board and both work
with these patches in addition to the other p1010rdb patches not included.

This series has one additional patch which replaces the mach/clock.h
with the linux/clkdev.h include.

Thanks,
Robin Holt
