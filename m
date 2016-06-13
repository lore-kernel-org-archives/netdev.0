From: Chris Paterson <Chris.Paterson2@renesas.com>
Subject: RE: [PATCH v6 0/2] Add CAN FD driver support to r8a7795 SoC
Date: Mon, 13 Jun 2016 07:12:48 +0000
Message-ID: <HK2PR0601MB132998862114783E29BCC507B7530@HK2PR0601MB1329.apcprd06.prod.outlook.com>
References: <SG2PR06MB1038056F44EFBCB51674B832C35D0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <1465367896-60207-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"horms@verge.net.au" <horms@verge.net.au>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>
To: "mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"ulrich.hecht@gmail.com" <ulrich.hecht@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:21373 "EHLO
	relmlie1.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030188AbcFMHM4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 03:12:56 -0400
In-Reply-To: <1465367896-60207-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ulrich, Oliver, David,

> 	* Addressed Ulrich's concerns on register, bits naming convention
Are Ramesh's proposed changes acceptable with you?


Kind regards, Chris


> -----Original Message-----
> From: Ramesh Shanmugasundaram
> [mailto:ramesh.shanmugasundaram@bp.renesas.com]
> Sent: 08 June 2016 07:38
> To: mkl@pengutronix.de; wg@grandegger.com; socketcan@hartkopp.net
> Cc: linux-can@vger.kernel.org; netdev@vger.kernel.org; Chris Paterson
> <Chris.Paterson2@renesas.com>; horms@verge.net.au;
> magnus.damm@gmail.com; ulrich.hecht@gmail.com; Ramesh
> Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
> Subject: [PATCH v6 0/2] Add CAN FD driver support to r8a7795 SoC
> 
> Hi All,
> 
>    This patch is based on can-next latest tag "linux-can-next-for-4.7-20160509"
> 
> Changes since v5:
> 	* Addressed Ulrich's concerns on register, bits naming convention
> 	* Rebased to latest tag (linux-can-next-for-4.7-20160509)
> 
> Changes since v4:
> 	* Rebased to latest can-next/testing branch
> 	* Addressed Marc K review comments on v2 patch
> 	* Use clk_get_rate() to find ext clock availability. Refer thread
> 	(https://lkml.org/lkml/2016/4/8/203)
> 
> Changes since v3:
> 	* Split v3 patch into two (Marc K)
> 	  (1) Introduce rcar_canfd.c driver in drivers/net/can/rcar dir
> 	  (2) Move rcar_can.c driver to new drivers/net/can/rcar dir
> 	* Added Acked-by Rob H for the bindings
> 	* Added comments on CAN FD only mode in driver & Kconfig (Oliver
> H)
> 
> Changes since v2:
> 	* Rebased to latest tag (linux-can-next-for-4.6-20160310)
> 	* Cleaned up leftover debugfs code (Thanks Oliver H)
> 	* Revised devicetree documentation text (as suggested by Rob H)
> 	  (https://www.mail-archive.com/linux-renesas-
> soc@vger.kernel.org/msg01597.html)
> 	* Used new can subsystem api to set static configuration & removed
> check in rcar_canfd_start (as suggested by Oliver H)
> 	  (Refer: http://comments.gmane.org/gmane.linux.can/9126 &
> 	   https://www.mail-archive.com/linux-renesas-
> soc@vger.kernel.org/msg01867.html)
> 	* Clubbed Renesas controller drivers to driver/net/can/rcar dir (as
> suggested by Oliver H)
> 	* Updated commit message
> 
> Changes since v1:
> 	* Removed testmodes & debugfs code (suggested by Oliver H)
> 	* Fixed tx path race issue by introducing lock (suggested by Marc K)
> 	* Removed __maybe_unused attribute of rcar_canfd_of_table
> 
> 
> Ramesh Shanmugasundaram (2):
>   can: rcar_canfd: Add Renesas R-Car CAN FD driver
>   can: rcar_can: Move Renesas CAN driver to rcar dir
> 
>  .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 +
>  drivers/net/can/Kconfig                            |   11 +-
>  drivers/net/can/Makefile                           |    2 +-
>  drivers/net/can/rcar/Kconfig                       |   21 +
>  drivers/net/can/rcar/Makefile                      |    6 +
>  drivers/net/can/{ => rcar}/rcar_can.c              |    0
>  drivers/net/can/rcar/rcar_canfd.c                  | 1695 ++++++++++++++++++++
>  7 files changed, 1813 insertions(+), 11 deletions(-)  create mode 100644
> Documentation/devicetree/bindings/net/can/rcar_canfd.txt
>  create mode 100644 drivers/net/can/rcar/Kconfig  create mode 100644
> drivers/net/can/rcar/Makefile  rename drivers/net/can/{ => rcar}/rcar_can.c
> (100%)  create mode 100644 drivers/net/can/rcar/rcar_canfd.c
> 
> --
> 1.9.1
