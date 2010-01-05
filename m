From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v2 0/3] can: mscan-mpc5xxx: add support for the
	Freescale MPC512x
Date: Tue,  5 Jan 2010 20:20:38 +0100
Message-ID: <1262719241-2422-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

This patch series adds support for the MPC512x from Freescale to
the mpc5xxx_can MSCAN driver.

Changes since v1:

- Various coding style issues, printk formats, variable names and
  error messagaes and typos fixes or improved

- MPC5xxx specific data are now passed to mpc5xxx_can_probe() via
  "of_device_id->data".

- The index of the MPC512x CAN controller is now derived directly
  from reg property. This allows use of_iomap() as usual.

- It has been documented that MPC512x Rev.1 CPUs are not supported.

Wolfgang

Wolfgang Grandegger (3):
  can: mscan: fix improper return if dlc < 8 in start_xmit function
  can: mscan-mpc5xxx: add support for the MPC512x processor
  powerpc/mpc5xxx: add OF platform binding doc for FSL MSCAN devices

 Documentation/powerpc/dts-bindings/fsl/can.txt     |   53 ++++
 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +-
 drivers/net/can/mscan/Kconfig                      |    7 +-
 drivers/net/can/mscan/mpc5xxx_can.c                |  258 ++++++++++++++++----
 drivers/net/can/mscan/mscan.c                      |   51 +++-
 drivers/net/can/mscan/mscan.h                      |   83 ++++---
 6 files changed, 357 insertions(+), 104 deletions(-)
 create mode 100644 Documentation/powerpc/dts-bindings/fsl/can.txt
