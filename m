From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 21/23] e1000e: remove redundant might_sleep()
Date: Sat, 21 Nov 2009 01:28:17 -0800
Message-ID: <20091121092816.5715.43262.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:59002
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752745AbZKUJ23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:28:29 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Now that mutex_lock() calls might_sleep() the driver doesn't have to here.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index fe6dc3d..f991b14 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -630,8 +630,6 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	u32 extcnf_ctrl, timeout = PHY_CFG_TIMEOUT;
 	s32 ret_val = 0;
 
-	might_sleep();
-
 	mutex_lock(&swflag_mutex);
 
 	while (timeout) {

