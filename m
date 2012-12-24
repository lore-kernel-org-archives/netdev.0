From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2 0/2] cpts fixes for v3.8-rc2
Date: Mon, 24 Dec 2012 08:19:08 +0100
Message-ID: <cover.1356331925.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sergei Shtylyov <sshtylyov@mvista.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed in v2:
Use clk_prepare_enable instead of clk_prepare + clk_enable.

The new cpts driver has two small issues, but it otherwise seems to be
working in -rc1.

Thanks,
Richard

Richard Cochran (2):
  cpts: fix build error by removing useless code.
  cpts: fix a run time warn_on.

 drivers/net/ethernet/ti/cpts.c |    3 +--
 drivers/net/ethernet/ti/cpts.h |    1 -
 2 files changed, 1 insertions(+), 3 deletions(-)

-- 
1.7.2.5

