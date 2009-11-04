From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 04/12] i2400m: keep index within ms_to_errno[]
Date: Wed,  4 Nov 2009 13:39:40 -0800
Message-ID: <a6346fa583766a51b7723288fc5d73ee5ea93479.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Cc: Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:31748 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758244AbZKDVlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:52 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Ensure that index `status' remains within ms_to_errno[]

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 0730868..8fe70e7 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -263,7 +263,7 @@ int i2400m_msg_check_status(const struct i2400m_l3l4_hdr *l3l4_hdr,
 
 	if (status == 0)
 		return 0;
-	if (status > ARRAY_SIZE(ms_to_errno)) {
+	if (status >= ARRAY_SIZE(ms_to_errno)) {
 		str = "unknown status code";
 		result = -EBADR;
 	} else {
-- 
1.6.2.5

