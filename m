From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the Linus' tree
Date: Mon, 11 Jan 2010 13:24:18 +1100
Message-ID: <20100111132418.8605a86c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sarveshwar Bandi <sarveshwarb@serverengines.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/benet/be_cmds.h between commit
fced9999ed7f6975fbb2350a73048918ba60a773 ("be2net: Bug fix to config NIC
appropriately before loopback test") from the Linus' tree and commit
368c0ca2f0a69b0818fbc1796d8e21ff02a61b4c ("be2net: implements ethtool
function to read eeprom data") from the net tree.

Just overlapping additions.  I have fixed ti up (see below) and can carry
the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/benet/be_cmds.h
index c002b83,6eed512..0000000
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@@ -926,5 -926,5 +940,7 @@@ extern int be_cmd_loopback_test(struct 
  				u32 num_pkts, u64 pattern);
  extern int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
  			u32 byte_cnt, struct be_dma_mem *cmd);
 +extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 +				u8 loopback_type, u8 enable);
+ extern int be_cmd_get_seeprom_data(struct be_adapter *adapter,
+ 				struct be_dma_mem *nonemb_cmd);
