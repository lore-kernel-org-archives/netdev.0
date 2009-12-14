From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 0/4] mx25: add support for FEC on i.MX25 PDK
Date: Mon, 14 Dec 2009 12:19:38 +0200
Message-ID: <cover.1260785451.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Baruch Siach <baruch@tkos.co.il>,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <kernel@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch series adds support for the FEC peripheral of the i.MX25 on the 
i.MX25 PDK board.

The first two patches are fixes for compilation and run failures. The third 
patch enables RMII if the FEC driver. Finally, the last patch adds the 
necessary board support code (pads, clock, etc.)

The FEC fix seems like an ugly hack to me. Suggestions for a better solution 
are welcome.

Baruch Siach (4):
  mx25: s/NO_PAD_CTL/NO_PAD_CTRL/
  mx25: don't force input on FEC pins
  fec: add support for Freescale i.MX25 PDK (3DS)
  mx25: add support for FEC on i.MX25 PDK

 arch/arm/mach-mx25/clock.c                  |    2 +
 arch/arm/mach-mx25/devices.c                |   19 ++++++++
 arch/arm/mach-mx25/devices.h                |    1 +
 arch/arm/mach-mx25/mx25pdk.c                |   40 ++++++++++++++++-
 arch/arm/plat-mxc/include/mach/iomux-mx25.h |   64 +++++++++++++-------------
 arch/arm/plat-mxc/include/mach/mx25.h       |    4 ++
 drivers/net/fec.c                           |   22 +++++++++
 drivers/net/fec.h                           |    2 +
 8 files changed, 121 insertions(+), 33 deletions(-)
