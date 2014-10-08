From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net: description of dma_cookie cause make xmldocs warning
Date: Wed,  8 Oct 2014 23:53:39 +0900
Message-ID: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Cc: dan.j.williams@intel.com, Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit 7bced397510ab569d31de4c70b39e13355046387,
dma_cookie was removed from struct skbuff.
But the description of dma_cookie still exist.
So the "make xmldocs" output following warning.

Warning(.//include/linux/skbuff.h:609): Excess struct/union
/enum/typedef member 'dma_cookie' description in 'sk_buff'

Remove description of dma_cookie fix the symptom.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 include/linux/skbuff.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a17ba08..9a86644 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -459,8 +459,6 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
- *	@dma_cookie: a cookie to one of several possible DMA operations
- *		done by skb DMA functions
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
  *	@mark: Generic packet mark
-- 
2.1.1.273.g97b8860
