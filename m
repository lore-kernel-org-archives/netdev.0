From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: add missing parenthesis to prevent u32
 overflow
Date: Wed, 4 Apr 2012 15:27:42 +0300
Message-ID: <1333542462-22658-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3096 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932131Ab2DDM2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 08:28:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Commit b475d78 lacked two pairs of parenthesis, causing an overflow in the
congestion management.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---

Hi Dave,

Please apply this patch to 'net-next'.

Thanks,
Dmitry

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index e6bb9f4..2b7a2bd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -409,7 +409,7 @@ static inline void bnx2x_init_min(const struct cmng_init_input *input_data,
 			 */
 			vdata->vnic_min_rate[vnic].vn_credit_delta =
 				(u32)input_data->vnic_min_rate[vnic] * 100 *
-				T_FAIR_COEF / (8 * 100 * vnicWeightSum);
+				(T_FAIR_COEF / (8 * 100 * vnicWeightSum));
 			if (vdata->vnic_min_rate[vnic].vn_credit_delta <
 			    pdata->fair_vars.fair_threshold +
 			    MIN_ABOVE_THRESH) {
@@ -446,7 +446,7 @@ static inline void bnx2x_init_fw_wrr(const struct cmng_init_input *input_data,
 				 */
 				ccd[cos] =
 				    (u32)input_data->cos_min_rate[cos] * 100 *
-				    T_FAIR_COEF / (8 * 100 * cosWeightSum);
+				    (T_FAIR_COEF / (8 * 100 * cosWeightSum));
 				 if (ccd[cos] < pdata->fair_vars.fair_threshold
 						+ MIN_ABOVE_THRESH) {
 					ccd[cos] =
-- 
1.7.9.rc2
