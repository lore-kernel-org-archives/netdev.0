From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: [PATCH v3 0/2] net: ethernet: davinci_emac: fixups + pm_runtime
Date: Fri, 20 Jul 2012 18:19:20 -0700
Message-ID: <1342833562-3435-1-git-send-email-mgreer@animalcreek.com>
Cc: linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	"Mark A. Greer" <mgreer@animalcreek.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mark A. Greer" <mgreer@animalcreek.com>

This series fixes a compile error in, and adds pm_runtime support
to, the davinci_emac driver.

To test on a davinci platform, you will need another patch just
submitted to netdev:

	http://marc.info/?l=linux-netdev&m=134282758408187&w=2

Mark A. Greer (2):
  net: ethernet: davinci_emac: Remove unnecessary #include
  net: ethernet: davinci_emac: add pm_runtime support

 drivers/net/ethernet/ti/davinci_emac.c | 45 +++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 23 deletions(-)

-- 
1.7.11.2

