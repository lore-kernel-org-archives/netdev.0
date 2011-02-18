From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH v2] net: dcb: match dcb_app protocol field with
	802.1Qaz spec
Date: Fri, 18 Feb 2011 15:30:17 -0800
Message-ID: <20110218233017.7419.32447.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shmulikr@broadcom.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:58944 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab1BRXf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 18:35:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dcb_app protocol field is a __u32 however the 802.1Qaz
specification defines it as a 16 bit field. This patch brings
the structure inline with the spec making it a __u16.

CC: Shmulik Ravid <shmulikr@broadcom.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/dcbnl.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 68cd248..66900e3 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -101,8 +101,8 @@ struct ieee_pfc {
  */
 struct dcb_app {
 	__u8	selector;
-	__u32	protocol;
 	__u8	priority;
+	__u16	protocol;
 };
 
 struct dcbmsg {

