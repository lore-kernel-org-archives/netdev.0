From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 3/7] cxgb3 - FW version update
Date: Sun, 25 Feb 2007 13:28:39 -0600
Message-ID: <1172431719.4717.8.camel@stevo-laptop>
References: <20070225004401.20831.3292.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:36279 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752395AbXBYT2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 14:28:41 -0500
In-Reply-To: <20070225004401.20831.3292.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Divy,

You missed a printk change.  Here is an updated patch.

------------

Update FW version to 3.2

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/cxgb3/t3_hw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 365a7f5..08a6295 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -884,11 +884,11 @@ int t3_check_fw_version(struct adapter *
 	major = G_FW_VERSION_MAJOR(vers);
 	minor = G_FW_VERSION_MINOR(vers);
 
-	if (type == FW_VERSION_T3 && major == 3 && minor == 1)
+	if (type == FW_VERSION_T3 && major == 3 && minor == 2)
 		return 0;
 
 	CH_ERR(adapter, "found wrong FW version(%u.%u), "
-	       "driver needs version 3.1\n", major, minor);
+	       "driver needs version 3.2\n", major, minor);
 	return -EINVAL;
 }
 


