From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-drivers-next tree with the
 net-next tree
Date: Mon, 16 May 2016 10:16:06 +1000
Message-ID: <20160516101606.751f9613@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

Today's linux-next merge of the wireless-drivers-next tree got a
conflict in:

  drivers/net/wireless/intel/iwlwifi/mvm/tx.c

between commit:

  909b27f70643 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")

from the net-next tree and commit:

  a525d0eab17d ("Merge tag 'iwlwifi-for-kalle-2016-05-04' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes")

from the wireless-drivers-next tree.

I fixed it up (I think that the net-next tree merge lost the changes
to iwl_mvm_set_tx_cmd() associated with commit 5c08b0f5026f ("iwlwifi:
mvm: don't override the rate with the AMSDU len")) and can carry the
fix as necessary. This is now fixed as far as linux-next is concerned,
but any non trivial conflicts should be mentioned to your upstream
maintainer when your tree is submitted for merging.  You may also want
to consider cooperating with the maintainer of the conflicting tree to
minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
