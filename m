From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 02/17] net: qca_framing: use u16 for frame offset
Date: Wed, 10 May 2017 10:53:13 +0200
Message-ID: <1494406408-31760-3-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It doesn't make sense to use a signed variable for offset here, so
fix it up.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_framing.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_framing.h b/drivers/net/ethernet/qualcomm/qca_framing.h
index d5e795d..8b385e6 100644
--- a/drivers/net/ethernet/qualcomm/qca_framing.h
+++ b/drivers/net/ethernet/qualcomm/qca_framing.h
@@ -103,7 +103,7 @@ struct qcafrm_handle {
 	enum qcafrm_state state;
 
 	/* Offset in buffer (borrowed for length too) */
-	s16 offset;
+	u16 offset;
 
 	/* Frame length as kept by this module */
 	u16 len;
-- 
2.1.4
