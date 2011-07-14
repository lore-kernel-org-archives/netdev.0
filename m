From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 2/6] qlcnic: updated supported cards information
Date: Thu, 14 Jul 2011 06:16:51 -0700
Message-ID: <1310649415-14787-3-git-send-email-amit.salecha@qlogic.com>
References: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:44912 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754886Ab1GNNZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 09:25:49 -0400
In-Reply-To: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Added QME8242-k 10GbE Dual Port Mezzanine Card to supported card info.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9899a79..7c0d6ee 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1510,6 +1510,8 @@ static const struct qlcnic_brdinfo qlcnic_boards[] = {
 		"NC523SFP 10Gb 2-port Server Adapter"},
 	{0x1077, 0x8020, 0x103c, 0x3346,
 		"CN1000Q Dual Port Converged Network Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x210,
+		"QME8242-k 10GbE Dual Port Mezzanine Card"},
 	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
 };
 
-- 
1.7.3.3

