From: Wenyou Yang <wenyou.yang@atmel.com>
Subject: [PATCH 1/2] can: m_can: Increase delay to ensure written INIT accepted
Date: Wed, 18 Nov 2015 18:04:08 +0800
Message-ID: <1447841049-5010-2-git-send-email-wenyou.yang@atmel.com>
References: <1447841049-5010-1-git-send-email-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Wenyou Yang <wenyou.yang@atmel.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447841049-5010-1-git-send-email-wenyou.yang@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Increase the delay time until the value written to INIT can be
read back to ensure that the previous value written to INIT has
been accepted.

Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>
---

 drivers/net/can/m_can/m_can.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index ef65517..fd1caa0 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -320,7 +320,7 @@ static inline void m_can_config_endisable(const struct m_can_priv *priv,
 					  bool enable)
 {
 	u32 cccr = m_can_read(priv, M_CAN_CCCR);
-	u32 timeout = 10;
+	u32 timeout = 1000;
 	u32 val = 0;
 
 	if (enable) {
-- 
1.7.9.5
