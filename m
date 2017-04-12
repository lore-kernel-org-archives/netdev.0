From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 1/7] net: define receive timestamp filter for NTP
Date: Wed, 12 Apr 2017 16:17:31 +0200
Message-ID: <20170412141737.5881-2-mlichvar@redhat.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62947 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752432AbdDLORo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:44 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add HWTSTAMP_FILTER_NTP_ALL to the hwtstamp_rx_filters enum for
timestamping of NTP packets. There is currently only one driver that
could support it directly, but it may change in the future.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 include/uapi/linux/net_tstamp.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 464dcca..0749fb1 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -125,6 +125,9 @@ enum hwtstamp_rx_filters {
 	HWTSTAMP_FILTER_PTP_V2_SYNC,
 	/* PTP v2/802.AS1, any layer, Delay_req packet */
 	HWTSTAMP_FILTER_PTP_V2_DELAY_REQ,
+
+	/* NTP, UDP, all versions and packet modes */
+	HWTSTAMP_FILTER_NTP_ALL,
 };
 
 #endif /* _NET_TIMESTAMPING_H */
-- 
2.9.3
