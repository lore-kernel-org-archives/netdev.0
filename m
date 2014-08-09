From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: myricom: myri10ge: myri10ge.c:  Cleaning up missing null-terminate after strncpy call
Date: Sun, 10 Aug 2014 01:40:38 +0200
Message-ID: <1407627638-24208-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-kernel@vger.kernel.org
To: Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added a guaranteed null-terminate after call to strncpy.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index f3d5d79..de327b6 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -574,6 +574,7 @@ myri10ge_validate_firmware(struct myri10ge_priv *mgp,
 
 	/* save firmware version for ethtool */
 	strncpy(mgp->fw_version, hdr->version, sizeof(mgp->fw_version));
+	mgp->fw_version[sizeif(mgp->fw_version) - 1] = '\0';
 
 	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
 	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);
-- 
1.7.10.4
