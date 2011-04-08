From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Fri, 8 Apr 2011 13:45:51 +1000
Message-ID: <20110408134551.521c6606.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/smsc911x.c between commit 25985edcedea ("Fix common
misspellings") from Linus' tree and commit dffc6b2432ea ("smsc911x: Use
pr_fmt, netdev_<level>, and netif_<level>") from the net tree.

I fixedd it up (see below) anc can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/smsc911x.c
index 4b42ecc,05a882e..0000000
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@@ -1669,7 -1669,7 +1669,7 @@@ static int smsc911x_eeprom_send_cmd(str
  	}
  
  	if (e2cmd & E2P_CMD_EPC_TIMEOUT_) {
- 		SMSC_TRACE(DRV, "Error occurred during eeprom operation");
 -		SMSC_TRACE(pdata, drv, "Error occured during eeprom operation");
++		SMSC_TRACE(pdata, drv, "Error occurred during eeprom operation");
  		return -EINVAL;
  	}
  
