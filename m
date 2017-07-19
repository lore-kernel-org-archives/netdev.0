From: Gabriel C <nix.or.die@gmail.com>
Subject: [PATCH] ath10k_htt_rx_amsdu_allowed(): use ath10k_dbg()
Date: Wed, 19 Jul 2017 17:37:08 +0200
Message-ID: <288fce5b-d738-f0ac-2433-67e1b35a0664@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ryan Hsu <ryanhsu@qti.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Kalle Valo <kvalo@qca.qualcomm.com>
To: "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36578 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933226AbdGSPhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:37:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


         Each time we get disconencted from AP we get flooded with messages like:

         ...
         ath10k_pci 0000:03:00.0: no channel configured; ignoring frame(s)!
         <until ratelimit kicks in>
         ath10k_warn: 155 callbacks suppressed
         ...

         Use ath10k_dbg() here too.

Signed-off-by: Gabriel Craciunescu <nix.or.die@gmail.com>
---
  drivers/net/wireless/ath/ath10k/htt_rx.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wireless/ath/ath10k/htt_rx.c
index 398dda978d6e..75d9b59b7e63 100644
--- a/drivers/net/wireless/ath/ath10k/htt_rx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
@@ -1514,7 +1514,7 @@ static bool ath10k_htt_rx_amsdu_allowed(struct ath10k *ar,
          */

         if (!rx_status->freq) {
-               ath10k_warn(ar, "no channel configured; ignoring frame(s)!\n");
+               ath10k_dbg(ar, ATH10K_DBG_HTT, "no channel configured; ignoring frame(s)!\n");
                 return false;
         }

-- 
2.13.3
