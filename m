From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: [PATCH v4 0/2] Add CAN FD driver support to r8a7795 SoC
Date: Mon, 21 Mar 2016 16:45:54 +0000
Message-ID: <1458578756-42898-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
References: <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	chris.paterson2@renesas.com,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
To: mkl@pengutronix.de, wg@grandegger.com, socketcan@hartkopp.net,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

   Thanks for the review comments.

   This patch is based on linux-can-next tag (linux-can-next-for-4.6-20160310)

   This patch depends on

   [RFC] [PATCH v4] can: fix handling of unmodifiable configuration options
   (http://permalink.gmane.org/gmane.linux.can/9148)

Changes since v3:
	* Split v3 patch into two (Marc K)
	  (1) Introduce rcar_canfd.c driver in drivers/net/can/rcar dir
	  (2) Move rcar_can.c driver to new drivers/net/can/rcar dir
	* Added Acked-by Rob H for the bindings
	* Added comments on CAN FD only mode in driver & Kconfig (Oliver H)

Changes since v2:
	* Rebased to latest tag (linux-can-next-for-4.6-20160310)
	* Cleaned up leftover debugfs code (Thanks Oliver H)
	* Revised devicetree documentation text (as suggested by Rob H)
	  (https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg01597.html)
	* Used new can subsystem api to set static configuration & removed check in rcar_canfd_start (as suggested by Oliver H)
	  (Refer: http://comments.gmane.org/gmane.linux.can/9126 &
	   https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg01867.html)
	* Clubbed Renesas controller drivers to driver/net/can/rcar dir (as suggested by Oliver H)
	* Updated commit message

Changes since v1:
	* Removed testmodes & debugfs code (suggested by Oliver H)
	* Fixed tx path race issue by introducing lock (suggested by Marc K)
	* Removed __maybe_unused attribute of rcar_canfd_of_table


Ramesh Shanmugasundaram (2):
  can: rcar_canfd: Add Renesas R-Car CAN FD driver
  can: rcar_can: Move Renesas CAN driver to rcar dir

 .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 ++
 drivers/net/can/Kconfig                            |   11 +-
 drivers/net/can/Makefile                           |    2 +-
 drivers/net/can/rcar/Kconfig                       |   21 +
 drivers/net/can/rcar/Makefile                      |    6 +
 drivers/net/can/{ => rcar}/rcar_can.c              |    0
 drivers/net/can/rcar/rcar_canfd.c                  | 1623 ++++++++++++++++++++
 7 files changed, 1741 insertions(+), 11 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/rcar_canfd.txt
 create mode 100644 drivers/net/can/rcar/Kconfig
 create mode 100644 drivers/net/can/rcar/Makefile
 rename drivers/net/can/{ => rcar}/rcar_can.c (100%)
 create mode 100644 drivers/net/can/rcar/rcar_canfd.c

-- 
1.9.1
