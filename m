From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: [PATCH] net/dec: Make __de_get_link_ksettings return void
Date: Sun,  4 Jun 2017 20:08:51 +0300
Message-ID: <20170604170851.3808-1-yuval.shaia@oracle.com>
To: davem@davemloft.net, jarod@redhat.com, yuval.shaia@oracle.com,
        tklauser@distanz.ch, tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-parisc@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make return value void since function never return meaningfull value

Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
---
 drivers/net/ethernet/dec/tulip/de2104x.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 91b8f6f..c87b8cc 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1483,8 +1483,8 @@ static void __de_get_regs(struct de_private *de, u8 *buf)
 	de_rx_missed(de, rbuf[8]);
 }
 
-static int __de_get_link_ksettings(struct de_private *de,
-				   struct ethtool_link_ksettings *cmd)
+static void __de_get_link_ksettings(struct de_private *de,
+				    struct ethtool_link_ksettings *cmd)
 {
 	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
 						de->media_supported);
@@ -1517,8 +1517,6 @@ static int __de_get_link_ksettings(struct de_private *de,
 		cmd->base.autoneg = AUTONEG_ENABLE;
 
 	/* ignore maxtxpkt, maxrxpkt for now */
