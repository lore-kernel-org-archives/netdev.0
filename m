From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH v2 0/9] can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:08 +0100
Message-ID: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Hello,

this series of patches changes the can driver's RX path. If a RTR frame is
received no data is copied.

As discussed on socketcan-core:
https://lists.berlios.de/pipermail/socketcan-core/2010-October/004836.html

cheers,
Marc

--

The following changes since commit e1928c86c4829703b800c81cc9edc939b5634e6f:

  cnic: Add FCoE support on 57712 (2010-12-23 11:44:34 -0800)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git public/can/rtr-for-net-next

Marc Kleine-Budde (9):
      can: at91_can: don't copy data to rx'ed RTR frames
      can: bfin_can: don't copy data to rx'ed RTR frames
      can: flexcan: don't copy data to rx'ed RTR frames
      can: sja1000: don't copy data to rx'ed RTR frames
      can: mcp251x: don't copy data to rx'ed RTR frames
      can: ti_hecc: don't copy data to rx'ed RTR frames
      can: janz-ican3: cleanup of ican3_to_can_frame and can_frame_to_ican3
      can: janz-ican3: don't copy data to rx'ed RTR frames
      can: pch_can: don't copy data to rx'ed RTR frames

 drivers/net/can/at91_can.c        |   10 ++++++----
 drivers/net/can/bfin_can.c        |   17 +++++++++--------
 drivers/net/can/flexcan.c         |   10 ++++++----
 drivers/net/can/janz-ican3.c      |   26 +++++++++++++++-----------
 drivers/net/can/mcp251x.c         |    3 ++-
 drivers/net/can/pch_can.c         |   15 ++++++++-------
 drivers/net/can/sja1000/sja1000.c |    7 +++----
 drivers/net/can/ti_hecc.c         |   18 ++++++++++--------
 8 files changed, 59 insertions(+), 47 deletions(-)
