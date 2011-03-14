From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 3/3] net: dcbnl: Add IEEE app selector value
	definitions
Date: Mon, 14 Mar 2011 12:01:15 -0700
Message-ID: <20110314190114.12070.94640.stgit@jf-dev1-dcblab>
References: <20110314190102.12070.21182.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63307 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754498Ab1CNTGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 15:06:55 -0400
In-Reply-To: <20110314190102.12070.21182.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

This adds defines for the app selector values currently
defined in the IEEE 802.1Qaz specification.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/dcbnl.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index eedf79b..c522800 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -125,6 +125,11 @@ struct cee_pfc {
 	__u8    tcs_supported;
 };
 
+/* IEEE 802.1Qaz std supported values */
+#define IEEE_8021QAZ_APP_SEL_ETHERTYPE	1
+#define IEEE_8021QAZ_APP_SEL_STREAM	2
+#define IEEE_8021QAZ_APP_SEL_DGRAM	3
+#define IEEE_8021QAZ_APP_SEL_ANY	4
 
 /* This structure contains the IEEE 802.1Qaz APP managed object. This
  * object is also used for the CEE std as well. There is no difference

