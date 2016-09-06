From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH 0/3] ath10k: a little bit clean-up of ATH10K driver
Date: Tue,  6 Sep 2016 21:39:55 +0900
Message-ID: <1473165598-28683-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kalle Valo <kvalo@qca.qualcomm.com>, Johannes Berg <johannes@sipsolutions.net>
To: linux-wireless@vger.kernel.org
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


Clean-up code with devm_clk_get() and devm_reset_control_get().

I know devm_reset_control_get() should be replaced with
either devm_reset_control_get_exclusive() or
devm_reset_control_get_shared().

My best guess is devm_reset_control_get_shared() for this case,
but I am not 100% sure, so I am leaving it to other developers.



Masahiro Yamada (3):
  ath10k: use devm_clk_get() instead of clk_get()
  ath10k: use devm_reset_control_get() instead of reset_control_get()
  ath10k: do not check if reset is NULL

 drivers/net/wireless/ath/ath10k/ahb.c | 105 +++++++---------------------------
 1 file changed, 21 insertions(+), 84 deletions(-)

-- 
1.9.1
