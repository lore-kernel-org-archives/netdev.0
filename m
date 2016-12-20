From: Geoff Lansberry <geoff@kuvee.com>
Subject: [PATCH 4/4] mod of frequency
Date: Tue, 20 Dec 2016 11:10:50 -0500
Message-ID: <1482250250-4192-7-git-send-email-glansberry@gmail.com>
References: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
        sameo@linux.intel.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, mgreer@animalcreek.com,
        justin@kuvee.com, Geoff Lansberry <glansberry@gmail.com>,
        Geoff Lansberry <geoff@kuvee.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:34444 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763458AbcLTQL0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 11:11:26 -0500
Received: by mail-qt0-f176.google.com with SMTP id n6so181220330qtd.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 08:11:26 -0800 (PST)
In-Reply-To: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
