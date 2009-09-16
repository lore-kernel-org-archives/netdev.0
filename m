From: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
Subject: [PATCH V3 0/2 -next] ems_usb: Added support for EMS CPC-USB/ARM7 CAN
	interface
Date: Wed, 16 Sep 2009 14:04:10 +0200
Message-ID: <20090916120409.30391.22292.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
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

The following series replaces the staging driver cpc-usb with the newly written
ems_usb CAN driver.

---

Sebastian Haas (2):
      ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB interface
      cpc-usb: Removed driver from staging tree


 drivers/net/can/Kconfig               |    7 
 drivers/net/can/Makefile              |    2 
 drivers/net/can/usb/Makefile          |    5 
 drivers/net/can/usb/ems_usb.c         | 1151 ++++++++++++++++++++++++++++++++
 drivers/staging/Kconfig               |    2 
 drivers/staging/Makefile              |    1 
 drivers/staging/cpc-usb/Kconfig       |    4 
 drivers/staging/cpc-usb/Makefile      |    3 
 drivers/staging/cpc-usb/TODO          |    9 
 drivers/staging/cpc-usb/cpc-usb_drv.c | 1185 ---------------------------------
 drivers/staging/cpc-usb/cpc.h         |  440 ------------
 drivers/staging/cpc-usb/cpc_int.h     |   83 --
 drivers/staging/cpc-usb/cpcusb.h      |   86 --
 drivers/staging/cpc-usb/sja2m16c.h    |   41 -
 drivers/staging/cpc-usb/sja2m16c_2.c  |  452 -------------
 15 files changed, 1165 insertions(+), 2306 deletions(-)
 create mode 100644 drivers/net/can/usb/Makefile
 create mode 100644 drivers/net/can/usb/ems_usb.c
 delete mode 100644 drivers/staging/cpc-usb/Kconfig
 delete mode 100644 drivers/staging/cpc-usb/Makefile
 delete mode 100644 drivers/staging/cpc-usb/TODO
 delete mode 100644 drivers/staging/cpc-usb/cpc-usb_drv.c
 delete mode 100644 drivers/staging/cpc-usb/cpc.h
 delete mode 100644 drivers/staging/cpc-usb/cpc_int.h
 delete mode 100644 drivers/staging/cpc-usb/cpcusb.h
 delete mode 100644 drivers/staging/cpc-usb/sja2m16c.h
 delete mode 100644 drivers/staging/cpc-usb/sja2m16c_2.c

-- 
Cheers, Sebastian
-- 
EMS Dr. Thomas Wuensche e.K.
Sonnenhang 3
85304 Ilmmuenster
HRA Neuburg a.d. Donau, HR-Nr. 70.106
Phone: +49-8441-490260
Fax  : +49-8441-81860
http://www.ems-wuensche.com
