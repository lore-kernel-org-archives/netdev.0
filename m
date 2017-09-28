From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 7/9] ptp: add offset for reserved field to header
Date: Thu, 28 Sep 2017 10:25:39 -0500
Message-ID: <1506612341-18061-8-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "Vivien Didelot" <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a four-byte "reserved" field at octet 16 in PTPv2.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 include/linux/ptp_classify.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
index a079656..b9b0073 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -47,6 +47,7 @@
 #define PTP_EV_PORT 319
 #define PTP_GEN_BIT 0x08 /* indicates general message, if set in message type */
 
+#define OFF_PTP_RESERVED	16 /* PTPv2 only */
 #define OFF_PTP_SOURCE_UUID	22 /* PTPv1 only */
 #define OFF_PTP_SEQUENCE_ID	30
 #define OFF_PTP_CONTROL		32 /* PTPv1 only */
-- 
2.1.4
