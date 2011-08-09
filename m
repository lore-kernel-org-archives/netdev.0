From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [Patch 0/4] [flexcan/powerpc] Add support for powerpc flexcan
	(freescale p1010) -V8
Date: Tue,  9 Aug 2011 07:28:23 -0500
Message-ID: <1312892907-20419-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
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

This patch set should have all your comments included.  It is based on
the David S. Miller net-next-2.6 tree commit 19fd617.

I have compiled each patch in the series individually for both arm and
powerpc (cheated on ppc and reordered them with the last patch first so
I could select CAN_FLEXCAN.

With all the patches applied, my p1010rdb works for communicating between
its two can ports and also can communicate with an external PSOC.  I have
done no testing beyond compile testing on an arm system as I have no
access to an arm based system.

For the first three patches in the series, I believe they are all ready
for submission to David S. Miller for the netdev tree.  This is the
first submission of patch 4 which, I believe, will end up going through
the linuxppc-dev list and can go at any time after the flexcan patches
are submitted.  As long the first and last patches are both applied,
the tree will compile for either ppc or arm, but will not work without
all patches.  If the ppc patch (4/4) gets applied before 1/4, we could
have a random config tester detect a compile failure on ppc if they
select NET, CAN, and CAN_FLEXCAN.

Thanks,
Robin Holt
