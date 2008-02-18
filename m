From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] tlan: add static to function definitions
Date: Mon, 18 Feb 2008 10:04:38 -0800
Message-ID: <1203357878.5757.26.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758916AbYBRSEq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The forward declarations were already marked static, make the definitions
be static as well.  Fixes the sparse warnings as well.

drivers/net/tlan.c:1403:5: warning: symbol 'TLan_HandleInvalid' was not declared. Should it be static?
drivers/net/tlan.c:1435:5: warning: symbol 'TLan_HandleTxEOF' was not declared. Should it be static?
drivers/net/tlan.c:1521:5: warning: symbol 'TLan_HandleStatOverflow' was not declared. Should it be static?
drivers/net/tlan.c:1557:5: warning: symbol 'TLan_HandleRxEOF' was not declared. Should it be static?
drivers/net/tlan.c:1692:5: warning: symbol 'TLan_HandleDummy' was not declared. Should it be static?
drivers/net/tlan.c:1722:5: warning: symbol 'TLan_HandleTxEOC' was not declared. Should it be static?
drivers/net/tlan.c:1770:5: warning: symbol 'TLan_HandleStatusCheck' was not declared. Should it be static?
drivers/net/tlan.c:1845:5: warning: symbol 'TLan_HandleRxEOC' was not declared. Should it be static?
drivers/net/tlan.c:1905:6: warning: symbol 'TLan_Timer' was not declared. Should it be static?
drivers/net/tlan.c:1986:6: warning: symbol 'TLan_ResetLists' was not declared. Should it be static?
drivers/net/tlan.c:2046:6: warning: symbol 'TLan_FreeLists' was not declared. Should it be static?
drivers/net/tlan.c:2095:6: warning: symbol 'TLan_PrintDio' was not declared. Should it be static?
drivers/net/tlan.c:2130:6: warning: symbol 'TLan_PrintList' was not declared. Should it be static?
drivers/net/tlan.c:2166:6: warning: symbol 'TLan_ReadAndClearStats' was not declared. Should it be static?
drivers/net/tlan.c:2242:1: warning: symbol 'TLan_ResetAdapter' was not declared. Should it be static?
drivers/net/tlan.c:2328:1: warning: symbol 'TLan_FinishReset' was not declared. Should it be static?
drivers/net/tlan.c:2451:6: warning: symbol 'TLan_SetMac' was not declared. Should it be static?
drivers/net/tlan.c:2493:6: warning: symbol 'TLan_PhyPrint' was not declared. Should it be static?
drivers/net/tlan.c:2542:6: warning: symbol 'TLan_PhyDetect' was not declared. Should it be static?
drivers/net/tlan.c:2589:6: warning: symbol 'TLan_PhyPowerDown' was not declared. Should it be static?
drivers/net/tlan.c:2614:6: warning: symbol 'TLan_PhyPowerUp' was not declared. Should it be static?
drivers/net/tlan.c:2635:6: warning: symbol 'TLan_PhyReset' was not declared. Should it be static?
drivers/net/tlan.c:2663:6: warning: symbol 'TLan_PhyStartLink' was not declared. Should it be static?
drivers/net/tlan.c:2750:6: warning: symbol 'TLan_PhyFinishAutoNeg' was not declared. Should it be static?
drivers/net/tlan.c:2906:5: warning: symbol 'TLan_MiiReadReg' was not declared. Should it be static?
drivers/net/tlan.c:2996:6: warning: symbol 'TLan_MiiSendData' was not declared. Should it be static?
drivers/net/tlan.c:3038:6: warning: symbol 'TLan_MiiSync' was not declared. Should it be static?
drivers/net/tlan.c:3077:6: warning: symbol 'TLan_MiiWriteReg' was not declared. Should it be static?
drivers/net/tlan.c:3147:6: warning: symbol 'TLan_EeSendStart' was not declared. Should it be static?
drivers/net/tlan.c:3187:5: warning: symbol 'TLan_EeSendByte' was not declared. Should it be static?
drivers/net/tlan.c:3248:6: warning: symbol 'TLan_EeReceiveByte' was not declared. Should it be static?
drivers/net/tlan.c:3306:5: warning: symbol 'TLan_EeReadByte' was not declared. Should it be static?

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Kept the style consistent with the rest of the file, checkpatch will complain.
 drivers/net/tlan.c |   64 ++++++++++++++++++++++++++--------------------------
 1 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 3af5b92..0166407 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1400,7 +1400,7 @@ static void TLan_SetMulticastList( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
 {
 	/* printk( "TLAN:  Invalid interrupt on %s.\n", dev->name ); */
 	return 0;
@@ -1432,7 +1432,7 @@ u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int		eoc = 0;
@@ -1518,7 +1518,7 @@ u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
 {
 	TLan_ReadAndClearStats( dev, TLAN_RECORD );
 
@@ -1554,7 +1554,7 @@ u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack = 0;
@@ -1689,7 +1689,7 @@ u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 {
 	printk( "TLAN:  Test interrupt on %s.\n", dev->name );
 	return 1;
@@ -1719,7 +1719,7 @@ u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	TLanList		*head_list;
@@ -1767,7 +1767,7 @@ u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack;
@@ -1842,7 +1842,7 @@ u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	dma_addr_t	head_list_phys;
@@ -1902,7 +1902,7 @@ u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-void TLan_Timer( unsigned long data )
+static void TLan_Timer( unsigned long data )
 {
 	struct net_device	*dev = (struct net_device *) data;
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -1983,7 +1983,7 @@ void TLan_Timer( unsigned long data )
 	 *
 	 **************************************************************/
 
-void TLan_ResetLists( struct net_device *dev )
+static void TLan_ResetLists( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
@@ -2043,7 +2043,7 @@ void TLan_ResetLists( struct net_device *dev )
 } /* TLan_ResetLists */
 
 
-void TLan_FreeLists( struct net_device *dev )
+static void TLan_FreeLists( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
@@ -2092,7 +2092,7 @@ void TLan_FreeLists( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-void TLan_PrintDio( u16 io_base )
+static void TLan_PrintDio( u16 io_base )
 {
 	u32 data0, data1;
 	int	i;
@@ -2127,7 +2127,7 @@ void TLan_PrintDio( u16 io_base )
 	 *
 	 **************************************************************/
 
-void TLan_PrintList( TLanList *list, char *type, int num)
+static void TLan_PrintList( TLanList *list, char *type, int num)
 {
 	int i;
 
@@ -2163,7 +2163,7 @@ void TLan_PrintList( TLanList *list, char *type, int num)
 	 *
 	 **************************************************************/
 
-void TLan_ReadAndClearStats( struct net_device *dev, int record )
+static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		tx_good, tx_under;
@@ -2238,7 +2238,7 @@ void TLan_ReadAndClearStats( struct net_device *dev, int record )
 	 *
 	 **************************************************************/
 
-void
+static void
 TLan_ResetAdapter( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -2324,7 +2324,7 @@ TLan_ResetAdapter( struct net_device *dev )
 
 
 
-void
+static void
 TLan_FinishReset( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -2448,7 +2448,7 @@ TLan_FinishReset( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-void TLan_SetMac( struct net_device *dev, int areg, char *mac )
+static void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 {
 	int i;
 
@@ -2490,7 +2490,7 @@ void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 	 *
 	 ********************************************************************/
 
-void TLan_PhyPrint( struct net_device *dev )
+static void TLan_PhyPrint( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16 i, data0, data1, data2, data3, phy;
@@ -2539,7 +2539,7 @@ void TLan_PhyPrint( struct net_device *dev )
 	 *
 	 ********************************************************************/
 
-void TLan_PhyDetect( struct net_device *dev )
+static void TLan_PhyDetect( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16		control;
@@ -2586,7 +2586,7 @@ void TLan_PhyDetect( struct net_device *dev )
 
 
 
-void TLan_PhyPowerDown( struct net_device *dev )
+static void TLan_PhyPowerDown( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
@@ -2611,7 +2611,7 @@ void TLan_PhyPowerDown( struct net_device *dev )
 
 
 
-void TLan_PhyPowerUp( struct net_device *dev )
+static void TLan_PhyPowerUp( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
@@ -2632,7 +2632,7 @@ void TLan_PhyPowerUp( struct net_device *dev )
 
 
 
-void TLan_PhyReset( struct net_device *dev )
+static void TLan_PhyReset( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		phy;
@@ -2660,7 +2660,7 @@ void TLan_PhyReset( struct net_device *dev )
 
 
 
-void TLan_PhyStartLink( struct net_device *dev )
+static void TLan_PhyStartLink( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		ability;
@@ -2747,7 +2747,7 @@ void TLan_PhyStartLink( struct net_device *dev )
 
 
 
-void TLan_PhyFinishAutoNeg( struct net_device *dev )
+static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		an_adv;
@@ -2903,7 +2903,7 @@ void TLan_PhyMonitor( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
+static int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 {
 	u8	nack;
 	u16	sio, tmp;
@@ -2993,7 +2993,7 @@ int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 	 *
 	 **************************************************************/
 
-void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
+static void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
 {
 	u16 sio;
 	u32 i;
@@ -3035,7 +3035,7 @@ void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
 	 *
 	 **************************************************************/
 
-void TLan_MiiSync( u16 base_port )
+static void TLan_MiiSync( u16 base_port )
 {
 	int i;
 	u16 sio;
@@ -3074,7 +3074,7 @@ void TLan_MiiSync( u16 base_port )
 	 *
 	 **************************************************************/
 
-void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
+static void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
 {
 	u16	sio;
 	int	minten;
@@ -3144,7 +3144,7 @@ void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
 	 *
 	 **************************************************************/
 
-void TLan_EeSendStart( u16 io_base )
+static void TLan_EeSendStart( u16 io_base )
 {
 	u16	sio;
 
@@ -3184,7 +3184,7 @@ void TLan_EeSendStart( u16 io_base )
 	 *
 	 **************************************************************/
 
-int TLan_EeSendByte( u16 io_base, u8 data, int stop )
+static int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 {
 	int	err;
 	u8	place;
@@ -3245,7 +3245,7 @@ int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 	 *
 	 **************************************************************/
 
-void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
+static void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 {
 	u8  place;
 	u16 sio;
@@ -3303,7 +3303,7 @@ void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 	 *
 	 **************************************************************/
 
-int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
+static int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
 {
 	int err;
 	TLanPrivateInfo *priv = netdev_priv(dev);
-- 
1.5.4.1.1278.gc75be
