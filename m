From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH 1/3] net: dcb: match dcb_app protocol field with
	802.1Qaz spec
Date: Mon, 31 Jan 2011 14:00:49 -0800
Message-ID: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31637 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab1AaWFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 17:05:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dcb_app protocol field is a __u32 however the 802.1Qaz
specification defines it as a 16 bit field. This patch brings
the structure inline with the spec making it a __u16.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/dcbnl.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 68cd248..bdc7ef4 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -101,7 +101,7 @@ struct ieee_pfc {
  */
 struct dcb_app {
 	__u8	selector;
-	__u32	protocol;
+	__u16	protocol;
 	__u8	priority;
 };
 

