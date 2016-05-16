From: Chris Paterson <Chris.Paterson2@renesas.com>
Subject: RE: [PATCH v5 0/2] Add CAN FD driver support to r8a7795 SoC
Date: Mon, 16 May 2016 15:52:40 +0000
Message-ID: <HK2PR0601MB1329C6D0F81CBF1E5F4640BBB7770@HK2PR0601MB1329.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1461846188-31249-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	Rob Herring <robh@kernel.org>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1461846188-31249-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc.

This patch series has been waiting for a response for a while now and we are keen to see it included upstream.

Are there any blocking points to it being accepted?


Kind regards, Chris


> -----Original Message-----
> From: Ramesh Shanmugasundaram
> [mailto:ramesh.shanmugasundaram@bp.renesas.com]
> Sent: 28 April 2016 13:23
> To: mkl@pengutronix.de; wg@grandegger.com; socketcan@hartkopp.net;
> robh+dt@kernel.org; pawel.moll@arm.com; mark.rutland@arm.com;
> ijc+devicetree@hellion.org.uk; galak@codeaurora.org
> Cc: linux-renesas-soc@vger.kernel.org; devicetree@vger.kernel.org; linux-
> can@vger.kernel.org; netdev@vger.kernel.org; Chris Paterson
> <Chris.Paterson2@renesas.com>; Ramesh Shanmugasundaram
> <ramesh.shanmugasundaram@bp.renesas.com>
> Subject: [PATCH v5 0/2] Add CAN FD driver support to r8a7795 SoC
> 
> Hi All,
> 
>    This patch is based on commit "885cc17abad6" of can-next/testing branch
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
> Ramesh Shanmugasundaram (2):
>   can: rcar_canfd: Add Renesas R-Car CAN FD driver
>   can: rcar_can: Move Renesas CAN driver to rcar dir
> 
>  .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 ++
>  drivers/net/can/Kconfig                            |   11 +-
>  drivers/net/can/Makefile                           |    2 +-
>  drivers/net/can/rcar/Kconfig                       |   21 +
>  drivers/net/can/rcar/Makefile                      |    6 +
>  drivers/net/can/{ => rcar}/rcar_can.c              |    0
>  drivers/net/can/rcar/rcar_canfd.c                  | 1624 ++++++++++++++++++++
>  7 files changed, 1742 insertions(+), 11 deletions(-)  create mode 100644
> Documentation/devicetree/bindings/net/can/rcar_canfd.txt
>  create mode 100644 drivers/net/can/rcar/Kconfig  create mode 100644
> drivers/net/can/rcar/Makefile  rename drivers/net/can/{ => rcar}/rcar_can.c
> (100%)  create mode 100644 drivers/net/can/rcar/rcar_canfd.c
> 
> --
> 1.9.1

