From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless tree with the net tree
Date: Wed, 21 Jul 2010 12:04:40 +1000
Message-ID: <20100721120440.46679304.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Today's linux-next merge of the wireless tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-commands.h between commit
ba2d3587912f82d1ab4367975b1df460db60fb1e ("drivers/net: use __packed
annotation") from the net tree and commit
7c094c5cc4d28062abf0d33ca022dbea6c522558 ("iwlwifi: additional statistic
debug counter") from the wireless tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-commands.h
index 8d2db9d,83247f7..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@@ -3035,8 -3035,9 +3035,9 @@@ struct iwl39_statistics_tx 
  struct statistics_dbg {
  	__le32 burst_check;
  	__le32 burst_count;
- 	__le32 reserved[4];
+ 	__le32 wait_for_silence_timeout_cnt;
+ 	__le32 reserved[3];
 -} __attribute__ ((packed));
 +} __packed;
  
  struct iwl39_statistics_div {
  	__le32 tx_on_a;
