From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net tree
Date: Fri, 5 Feb 2010 13:37:47 +1100
Message-ID: <20100205133747.14ca83f2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Adam Buchbinder <adam.buchbinder@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
drivers/net/sfc/mcdi_pcol.h between commit
5297a98d5dd6de86fe1e2ffc9ea60cdf59b71443 ("sfc: Update MCDI protocol
definitions") from the net tree and commit
4887b438e6880c73c4b44d868211e70c1f3deaec ("Fix misspelling of
"successful" and variants in comments") from the trivial tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/sfc/mcdi_pcol.h
index bd59302,f61e1de..0000000
--- a/drivers/net/sfc/mcdi_pcol.h
+++ b/drivers/net/sfc/mcdi_pcol.h
@@@ -859,14 -852,11 +859,14 @@@
  /* MC_CMD_POLL_PHY_BIST: (variadic output)
   * Poll for BIST completion
   *
 - * Returns a single status code, and a binary blob of phy-specific
 - * bist output. If the driver can't successfully parse the BIST output,
 - * it should still respect the Pass/Fail in OUT.RESULT.
 + * Returns a single status code, and optionally some PHY specific
 + * bist output. The driver should only consume the BIST output
 + * after validating OUTLEN and PHY_CFG.PHY_TYPE.
   *
-  * If a driver can't succesfully parse the BIST output, it should
 - * Locks required: PHY_LOCK  if doing a  PHY BIST
++ * If a driver can't successfully parse the BIST output, it should
 + * still respect the pass/Fail in OUT.RESULT
 + *
 + * Locks required: PHY_LOCK if doing a  PHY BIST
   * Return code: 0, EACCES (if PHY_LOCK is not held)
   */
  #define MC_CMD_POLL_BIST 0x26
