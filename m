From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: updates to the mscan-driver in net-next
Date: Mon, 16 Nov 2009 23:57:43 +0100
Message-ID: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

here are the patches which fix the issues for the mscan & mpc52xx_can drivers
raised by Wolfgang Grandegger and Grant Likely. They are based on the initial
version of the drivers I sent a few days ago. Devicetree-discuss has been added
for the property changes. I will also update my branch on pengutronix.de
tomorrow, I seem to have issues when trying that from home :(^

Regards,

   Wolfram


Wolfram Sang (11):
      net/can/mscan: move defines into .h file
      net/can/mscan: trivial fixes
      net/can/mscan: drop support for CAN_MODE_{SLEEP|STOP}
      net/can/mscan: use {clr|set}bits8 macros
      net/can/mscan: fix function annotations
      net/can/mscan: drop assignment in while-construct
      net/can/mpc52xx_can: refactor clock-get routine
      net/can/mpc52xx_can: improve properties and their description
      net/can/mscan: replace hardcoded values with defines
      net/can/mscan: add error path to mscan_open()
      net/can/mscan: improve build

 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +-
 drivers/net/can/Kconfig                            |   19 +---
 drivers/net/can/mscan/Kconfig                      |   23 ++++
 drivers/net/can/mscan/Makefile                     |    4 +-
 .../net/can/mscan/{mpc52xx_can.c => mpc5xxx_can.c} |   64 ++++-------
 drivers/net/can/mscan/mscan.c                      |  121 +++++++------------
 drivers/net/can/mscan/mscan.h                      |   36 ++++++-
 7 files changed, 133 insertions(+), 143 deletions(-)
 create mode 100644 drivers/net/can/mscan/Kconfig
 rename drivers/net/can/mscan/{mpc52xx_can.c => mpc5xxx_can.c} (90%)
