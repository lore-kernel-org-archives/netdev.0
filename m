From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 2/3] 3c59x: cleanup init of module parameter arrays
Date: Mon, 12 Sep 2005 10:48:53 -0400
Message-ID: <09122005104853.31588@bilbo.tuxdriver.com>
References: <09122005104852.31525@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751352AbVILPDe@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104852.31525@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beautify the array initilizations for the module parameters.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/3c59x.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -903,12 +903,12 @@ static void set_8021q_mode(struct net_de
 /* This driver uses 'options' to pass the media type, full-duplex flag, etc. */
 /* Option count limit only -- unlimited interfaces are supported. */
 #define MAX_UNITS 8
-static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
-static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int hw_checksums[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int flow_ctrl[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int enable_wol[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int use_mmio[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int options[MAX_UNITS] = { [0 ... MAX_UNITS-1] = -1 };
+static int full_duplex[MAX_UNITS] = { [0 ... MAX_UNITS-1] = -1 };
+static int hw_checksums[MAX_UNITS] = { [0 ... MAX_UNITS-1] = -1 };
+static int flow_ctrl[MAX_UNITS] = { [0 ... MAX_UNITS-1] = -1 };
+static int enable_wol[MAX_UNITS] = { [0 ... MAX_UNITS-1] = -1 };
+static int use_mmio[MAX_UNITS] = { [0 ... MAX_UNITS-1] = -1 };
 static int global_options = -1;
 static int global_full_duplex = -1;
 static int global_enable_wol = -1;
