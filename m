From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 02/10] net: thunderx: fix constants
Date: Tue, 2 Jun 2015 11:00:19 -0700
Message-ID: <1433268028-23992-3-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes sparse messages like this:

drivers/net/ethernet/cavium/thunder/thunder_bgx.c:897:24: sparse:
constant 0x300000000000 is so big it is long

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index abd446e6..f81182c 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -326,11 +326,11 @@ static int nicvf_rss_init(struct nicvf *nic)
 	rss->enable = true;
 
 	/* Using the HW reset value for now */
-	rss->key[0] = 0xFEED0BADFEED0BAD;
-	rss->key[1] = 0xFEED0BADFEED0BAD;
-	rss->key[2] = 0xFEED0BADFEED0BAD;
-	rss->key[3] = 0xFEED0BADFEED0BAD;
-	rss->key[4] = 0xFEED0BADFEED0BAD;
+	rss->key[0] = 0xFEED0BADFEED0BADULL;
+	rss->key[1] = 0xFEED0BADFEED0BADULL;
+	rss->key[2] = 0xFEED0BADFEED0BADULL;
+	rss->key[3] = 0xFEED0BADFEED0BADULL;
+	rss->key[4] = 0xFEED0BADFEED0BADULL;
 
 	nicvf_set_rss_key(nic);
 
-- 
2.4.1
