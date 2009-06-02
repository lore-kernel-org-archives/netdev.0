From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/7] e1000e: enable CRC stripping by default
Date: Tue, 02 Jun 2009 14:28:01 -0700
Message-ID: <20090602212800.24614.45798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:49464
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbZFBV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:28:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

CRC stripping should be enabled by default but was not if it was not
specified as a module parameter.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/param.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index e909f96..1342e0b 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -427,6 +427,8 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			e1000_validate_option(&crc_stripping, &opt, adapter);
 			if (crc_stripping == OPTION_ENABLED)
 				adapter->flags2 |= FLAG2_CRC_STRIPPING;
+		} else {
+			adapter->flags2 |= FLAG2_CRC_STRIPPING;
 		}
 	}
 	{ /* Kumeran Lock Loss Workaround */

