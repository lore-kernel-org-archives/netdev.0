From: Geoff Lansberry <geoff@kuvee.com>
Subject: [PATCH 3/3] mod of frequency
Date: Tue, 20 Dec 2016 11:10:48 -0500
Message-ID: <1482250250-4192-5-git-send-email-glansberry@gmail.com>
References: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
        sameo@linux.intel.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, mgreer@animalcreek.com,
        justin@kuvee.com, Geoff Lansberry <glansberry@gmail.com>,
        Geoff Lansberry <geoff@kuvee.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 drivers/nfc/trf7970a.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index e9e93ea..5916737 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -2076,10 +2076,10 @@ static int trf7970a_probe(struct spi_device *spi)
 	of_property_read_u32(np, "clock-frequency", &clk_freq);
 	if ((clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY) ||
 		(clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY)) {
-	        dev_err(trf->dev,
-	                "clock-frequency (%u Hz) unsupported\n",
-	                clk_freq);
-	        return -EINVAL;
+		dev_err(trf->dev,
+			"clock-frequency (%u Hz) unsupported\n",
+			clk_freq);
+		return -EINVAL;
 	}
 
 	if (of_property_read_bool(np, "en2-rf-quirk"))
-- 
Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
