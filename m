From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 6/6] tc35815: Whitespace cleanup
Date: Fri, 11 Apr 2008 00:25:31 +0900 (JST)
Message-ID: <20080411.002531.72708711.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:53138 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758070AbYDJPYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:24:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic TAB/whitespace cleanups and some style cleanups.  No
functional changes.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |  372 +++++++++++++++++++++++++------------------------
 1 files changed, 187 insertions(+), 185 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index de8b18e..090f46e 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -81,7 +81,7 @@ static const struct pci_device_id tc35815_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939), .driver_data = TC35815_TX4939 },
 	{0,}
 };
-MODULE_DEVICE_TABLE (pci, tc35815_pci_tbl);
+MODULE_DEVICE_TABLE(pci, tc35815_pci_tbl);
 
 /* see MODULE_PARM_DESC */
 static struct tc35815_options {
@@ -130,159 +130,159 @@ struct tc35815_regs {
  * Bit assignments
  */
 /* DMA_Ctl bit asign ------------------------------------------------------- */
-#define DMA_RxAlign            0x00c00000 /* 1:Reception Alignment           */
-#define DMA_RxAlign_1          0x00400000
-#define DMA_RxAlign_2          0x00800000
-#define DMA_RxAlign_3          0x00c00000
-#define DMA_M66EnStat          0x00080000 /* 1:66MHz Enable State            */
-#define DMA_IntMask            0x00040000 /* 1:Interupt mask                 */
-#define DMA_SWIntReq           0x00020000 /* 1:Software Interrupt request    */
-#define DMA_TxWakeUp           0x00010000 /* 1:Transmit Wake Up              */
-#define DMA_RxBigE             0x00008000 /* 1:Receive Big Endian            */
-#define DMA_TxBigE             0x00004000 /* 1:Transmit Big Endian           */
-#define DMA_TestMode           0x00002000 /* 1:Test Mode                     */
-#define DMA_PowrMgmnt          0x00001000 /* 1:Power Management              */
-#define DMA_DmBurst_Mask       0x000001fc /* DMA Burst size                  */
+#define DMA_RxAlign	       0x00c00000 /* 1:Reception Alignment	     */
+#define DMA_RxAlign_1	       0x00400000
+#define DMA_RxAlign_2	       0x00800000
+#define DMA_RxAlign_3	       0x00c00000
+#define DMA_M66EnStat	       0x00080000 /* 1:66MHz Enable State	     */
+#define DMA_IntMask	       0x00040000 /* 1:Interupt mask		     */
+#define DMA_SWIntReq	       0x00020000 /* 1:Software Interrupt request    */
+#define DMA_TxWakeUp	       0x00010000 /* 1:Transmit Wake Up		     */
+#define DMA_RxBigE	       0x00008000 /* 1:Receive Big Endian	     */
+#define DMA_TxBigE	       0x00004000 /* 1:Transmit Big Endian	     */
+#define DMA_TestMode	       0x00002000 /* 1:Test Mode		     */
+#define DMA_PowrMgmnt	       0x00001000 /* 1:Power Management		     */
+#define DMA_DmBurst_Mask       0x000001fc /* DMA Burst size		     */
 
 /* RxFragSize bit asign ---------------------------------------------------- */
-#define RxFrag_EnPack          0x00008000 /* 1:Enable Packing                */
-#define RxFrag_MinFragMask     0x00000ffc /* Minimum Fragment                */
+#define RxFrag_EnPack	       0x00008000 /* 1:Enable Packing		     */
+#define RxFrag_MinFragMask     0x00000ffc /* Minimum Fragment		     */
 
 /* MAC_Ctl bit asign ------------------------------------------------------- */
-#define MAC_Link10             0x00008000 /* 1:Link Status 10Mbits           */
-#define MAC_EnMissRoll         0x00002000 /* 1:Enable Missed Roll            */
-#define MAC_MissRoll           0x00000400 /* 1:Missed Roll                   */
-#define MAC_Loop10             0x00000080 /* 1:Loop 10 Mbps                  */
-#define MAC_Conn_Auto          0x00000000 /*00:Connection mode (Automatic)   */
-#define MAC_Conn_10M           0x00000020 /*01:                (10Mbps endec)*/
-#define MAC_Conn_Mll           0x00000040 /*10:                (Mll clock)   */
-#define MAC_MacLoop            0x00000010 /* 1:MAC Loopback                  */
-#define MAC_FullDup            0x00000008 /* 1:Full Duplex 0:Half Duplex     */
-#define MAC_Reset              0x00000004 /* 1:Software Reset                */
-#define MAC_HaltImm            0x00000002 /* 1:Halt Immediate                */
-#define MAC_HaltReq            0x00000001 /* 1:Halt request                  */
+#define MAC_Link10	       0x00008000 /* 1:Link Status 10Mbits	     */
+#define MAC_EnMissRoll	       0x00002000 /* 1:Enable Missed Roll	     */
+#define MAC_MissRoll	       0x00000400 /* 1:Missed Roll		     */
+#define MAC_Loop10	       0x00000080 /* 1:Loop 10 Mbps		     */
+#define MAC_Conn_Auto	       0x00000000 /*00:Connection mode (Automatic)   */
+#define MAC_Conn_10M	       0x00000020 /*01:		       (10Mbps endec)*/
+#define MAC_Conn_Mll	       0x00000040 /*10:		       (Mll clock)   */
+#define MAC_MacLoop	       0x00000010 /* 1:MAC Loopback		     */
+#define MAC_FullDup	       0x00000008 /* 1:Full Duplex 0:Half Duplex     */
+#define MAC_Reset	       0x00000004 /* 1:Software Reset		     */
+#define MAC_HaltImm	       0x00000002 /* 1:Halt Immediate		     */
+#define MAC_HaltReq	       0x00000001 /* 1:Halt request		     */
 
 /* PROM_Ctl bit asign ------------------------------------------------------ */
-#define PROM_Busy              0x00008000 /* 1:Busy (Start Operation)        */
-#define PROM_Read              0x00004000 /*10:Read operation                */
-#define PROM_Write             0x00002000 /*01:Write operation               */
-#define PROM_Erase             0x00006000 /*11:Erase operation               */
-                                          /*00:Enable or Disable Writting,   */
-                                          /*      as specified in PROM_Addr. */
-#define PROM_Addr_Ena          0x00000030 /*11xxxx:PROM Write enable         */
-                                          /*00xxxx:           disable        */
+#define PROM_Busy	       0x00008000 /* 1:Busy (Start Operation)	     */
+#define PROM_Read	       0x00004000 /*10:Read operation		     */
+#define PROM_Write	       0x00002000 /*01:Write operation		     */
+#define PROM_Erase	       0x00006000 /*11:Erase operation		     */
+					  /*00:Enable or Disable Writting,   */
+					  /*	  as specified in PROM_Addr. */
+#define PROM_Addr_Ena	       0x00000030 /*11xxxx:PROM Write enable	     */
+					  /*00xxxx:	      disable	     */
 
 /* CAM_Ctl bit asign ------------------------------------------------------- */
-#define CAM_CompEn             0x00000010 /* 1:CAM Compare Enable            */
-#define CAM_NegCAM             0x00000008 /* 1:Reject packets CAM recognizes,*/
-                                          /*                    accept other */
-#define CAM_BroadAcc           0x00000004 /* 1:Broadcast assept              */
-#define CAM_GroupAcc           0x00000002 /* 1:Multicast assept              */
-#define CAM_StationAcc         0x00000001 /* 1:unicast accept                */
+#define CAM_CompEn	       0x00000010 /* 1:CAM Compare Enable	     */
+#define CAM_NegCAM	       0x00000008 /* 1:Reject packets CAM recognizes,*/
+					  /*			accept other */
+#define CAM_BroadAcc	       0x00000004 /* 1:Broadcast assept		     */
+#define CAM_GroupAcc	       0x00000002 /* 1:Multicast assept		     */
+#define CAM_StationAcc	       0x00000001 /* 1:unicast accept		     */
 
 /* CAM_Ena bit asign ------------------------------------------------------- */
-#define CAM_ENTRY_MAX                  21   /* CAM Data entry max count      */
+#define CAM_ENTRY_MAX		       21   /* CAM Data entry max count	     */
 #define CAM_Ena_Mask ((1<<CAM_ENTRY_MAX)-1) /* CAM Enable bits (Max 21bits)  */
-#define CAM_Ena_Bit(index)         (1<<(index))
+#define CAM_Ena_Bit(index)	(1 << (index))
 #define CAM_ENTRY_DESTINATION	0
 #define CAM_ENTRY_SOURCE	1
 #define CAM_ENTRY_MACCTL	20
 
 /* Tx_Ctl bit asign -------------------------------------------------------- */
-#define Tx_En                  0x00000001 /* 1:Transmit enable               */
-#define Tx_TxHalt              0x00000002 /* 1:Transmit Halt Request         */
-#define Tx_NoPad               0x00000004 /* 1:Suppress Padding              */
-#define Tx_NoCRC               0x00000008 /* 1:Suppress Padding              */
-#define Tx_FBack               0x00000010 /* 1:Fast Back-off                 */
-#define Tx_EnUnder             0x00000100 /* 1:Enable Underrun               */
-#define Tx_EnExDefer           0x00000200 /* 1:Enable Excessive Deferral     */
-#define Tx_EnLCarr             0x00000400 /* 1:Enable Lost Carrier           */
-#define Tx_EnExColl            0x00000800 /* 1:Enable Excessive Collision    */
-#define Tx_EnLateColl          0x00001000 /* 1:Enable Late Collision         */
-#define Tx_EnTxPar             0x00002000 /* 1:Enable Transmit Parity        */
-#define Tx_EnComp              0x00004000 /* 1:Enable Completion             */
+#define Tx_En		       0x00000001 /* 1:Transmit enable		     */
+#define Tx_TxHalt	       0x00000002 /* 1:Transmit Halt Request	     */
+#define Tx_NoPad	       0x00000004 /* 1:Suppress Padding		     */
+#define Tx_NoCRC	       0x00000008 /* 1:Suppress Padding		     */
+#define Tx_FBack	       0x00000010 /* 1:Fast Back-off		     */
+#define Tx_EnUnder	       0x00000100 /* 1:Enable Underrun		     */
+#define Tx_EnExDefer	       0x00000200 /* 1:Enable Excessive Deferral     */
+#define Tx_EnLCarr	       0x00000400 /* 1:Enable Lost Carrier	     */
+#define Tx_EnExColl	       0x00000800 /* 1:Enable Excessive Collision    */
+#define Tx_EnLateColl	       0x00001000 /* 1:Enable Late Collision	     */
+#define Tx_EnTxPar	       0x00002000 /* 1:Enable Transmit Parity	     */
+#define Tx_EnComp	       0x00004000 /* 1:Enable Completion	     */
 
 /* Tx_Stat bit asign ------------------------------------------------------- */
-#define Tx_TxColl_MASK         0x0000000F /* Tx Collision Count              */
-#define Tx_ExColl              0x00000010 /* Excessive Collision             */
-#define Tx_TXDefer             0x00000020 /* Transmit Defered                */
-#define Tx_Paused              0x00000040 /* Transmit Paused                 */
-#define Tx_IntTx               0x00000080 /* Interrupt on Tx                 */
-#define Tx_Under               0x00000100 /* Underrun                        */
-#define Tx_Defer               0x00000200 /* Deferral                        */
-#define Tx_NCarr               0x00000400 /* No Carrier                      */
-#define Tx_10Stat              0x00000800 /* 10Mbps Status                   */
-#define Tx_LateColl            0x00001000 /* Late Collision                  */
-#define Tx_TxPar               0x00002000 /* Tx Parity Error                 */
-#define Tx_Comp                0x00004000 /* Completion                      */
-#define Tx_Halted              0x00008000 /* Tx Halted                       */
-#define Tx_SQErr               0x00010000 /* Signal Quality Error(SQE)       */
+#define Tx_TxColl_MASK	       0x0000000F /* Tx Collision Count		     */
+#define Tx_ExColl	       0x00000010 /* Excessive Collision	     */
+#define Tx_TXDefer	       0x00000020 /* Transmit Defered		     */
+#define Tx_Paused	       0x00000040 /* Transmit Paused		     */
+#define Tx_IntTx	       0x00000080 /* Interrupt on Tx		     */
+#define Tx_Under	       0x00000100 /* Underrun			     */
+#define Tx_Defer	       0x00000200 /* Deferral			     */
+#define Tx_NCarr	       0x00000400 /* No Carrier			     */
+#define Tx_10Stat	       0x00000800 /* 10Mbps Status		     */
+#define Tx_LateColl	       0x00001000 /* Late Collision		     */
+#define Tx_TxPar	       0x00002000 /* Tx Parity Error		     */
+#define Tx_Comp		       0x00004000 /* Completion			     */
+#define Tx_Halted	       0x00008000 /* Tx Halted			     */
+#define Tx_SQErr	       0x00010000 /* Signal Quality Error(SQE)	     */
 
 /* Rx_Ctl bit asign -------------------------------------------------------- */
-#define Rx_EnGood              0x00004000 /* 1:Enable Good                   */
-#define Rx_EnRxPar             0x00002000 /* 1:Enable Receive Parity         */
-#define Rx_EnLongErr           0x00000800 /* 1:Enable Long Error             */
-#define Rx_EnOver              0x00000400 /* 1:Enable OverFlow               */
-#define Rx_EnCRCErr            0x00000200 /* 1:Enable CRC Error              */
-#define Rx_EnAlign             0x00000100 /* 1:Enable Alignment              */
-#define Rx_IgnoreCRC           0x00000040 /* 1:Ignore CRC Value              */
-#define Rx_StripCRC            0x00000010 /* 1:Strip CRC Value               */
-#define Rx_ShortEn             0x00000008 /* 1:Short Enable                  */
-#define Rx_LongEn              0x00000004 /* 1:Long Enable                   */
-#define Rx_RxHalt              0x00000002 /* 1:Receive Halt Request          */
-#define Rx_RxEn                0x00000001 /* 1:Receive Intrrupt Enable       */
+#define Rx_EnGood	       0x00004000 /* 1:Enable Good		     */
+#define Rx_EnRxPar	       0x00002000 /* 1:Enable Receive Parity	     */
+#define Rx_EnLongErr	       0x00000800 /* 1:Enable Long Error	     */
+#define Rx_EnOver	       0x00000400 /* 1:Enable OverFlow		     */
+#define Rx_EnCRCErr	       0x00000200 /* 1:Enable CRC Error		     */
+#define Rx_EnAlign	       0x00000100 /* 1:Enable Alignment		     */
+#define Rx_IgnoreCRC	       0x00000040 /* 1:Ignore CRC Value		     */
+#define Rx_StripCRC	       0x00000010 /* 1:Strip CRC Value		     */
+#define Rx_ShortEn	       0x00000008 /* 1:Short Enable		     */
+#define Rx_LongEn	       0x00000004 /* 1:Long Enable		     */
+#define Rx_RxHalt	       0x00000002 /* 1:Receive Halt Request	     */
+#define Rx_RxEn		       0x00000001 /* 1:Receive Intrrupt Enable	     */
 
 /* Rx_Stat bit asign ------------------------------------------------------- */
-#define Rx_Halted              0x00008000 /* Rx Halted                       */
-#define Rx_Good                0x00004000 /* Rx Good                         */
-#define Rx_RxPar               0x00002000 /* Rx Parity Error                 */
-                            /* 0x00001000    not use                         */
-#define Rx_LongErr             0x00000800 /* Rx Long Error                   */
-#define Rx_Over                0x00000400 /* Rx Overflow                     */
-#define Rx_CRCErr              0x00000200 /* Rx CRC Error                    */
-#define Rx_Align               0x00000100 /* Rx Alignment Error              */
-#define Rx_10Stat              0x00000080 /* Rx 10Mbps Status                */
-#define Rx_IntRx               0x00000040 /* Rx Interrupt                    */
-#define Rx_CtlRecd             0x00000020 /* Rx Control Receive              */
-
-#define Rx_Stat_Mask           0x0000EFC0 /* Rx All Status Mask              */
+#define Rx_Halted	       0x00008000 /* Rx Halted			     */
+#define Rx_Good		       0x00004000 /* Rx Good			     */
+#define Rx_RxPar	       0x00002000 /* Rx Parity Error		     */
+			    /* 0x00001000    not use			     */
+#define Rx_LongErr	       0x00000800 /* Rx Long Error		     */
+#define Rx_Over		       0x00000400 /* Rx Overflow		     */
+#define Rx_CRCErr	       0x00000200 /* Rx CRC Error		     */
+#define Rx_Align	       0x00000100 /* Rx Alignment Error		     */
+#define Rx_10Stat	       0x00000080 /* Rx 10Mbps Status		     */
+#define Rx_IntRx	       0x00000040 /* Rx Interrupt		     */
+#define Rx_CtlRecd	       0x00000020 /* Rx Control Receive		     */
+
+#define Rx_Stat_Mask	       0x0000EFC0 /* Rx All Status Mask		     */
 
 /* Int_En bit asign -------------------------------------------------------- */
-#define Int_NRAbtEn            0x00000800 /* 1:Non-recoverable Abort Enable  */
-#define Int_TxCtlCmpEn         0x00000400 /* 1:Transmit Control Complete Enable */
-#define Int_DmParErrEn         0x00000200 /* 1:DMA Parity Error Enable       */
-#define Int_DParDEn            0x00000100 /* 1:Data Parity Error Enable      */
-#define Int_EarNotEn           0x00000080 /* 1:Early Notify Enable           */
-#define Int_DParErrEn          0x00000040 /* 1:Detected Parity Error Enable  */
-#define Int_SSysErrEn          0x00000020 /* 1:Signalled System Error Enable */
-#define Int_RMasAbtEn          0x00000010 /* 1:Received Master Abort Enable  */
-#define Int_RTargAbtEn         0x00000008 /* 1:Received Target Abort Enable  */
-#define Int_STargAbtEn         0x00000004 /* 1:Signalled Target Abort Enable */
-#define Int_BLExEn             0x00000002 /* 1:Buffer List Exhausted Enable  */
-#define Int_FDAExEn            0x00000001 /* 1:Free Descriptor Area          */
-                                          /*               Exhausted Enable  */
+#define Int_NRAbtEn	       0x00000800 /* 1:Non-recoverable Abort Enable  */
+#define Int_TxCtlCmpEn	       0x00000400 /* 1:Transmit Ctl Complete Enable  */
+#define Int_DmParErrEn	       0x00000200 /* 1:DMA Parity Error Enable	     */
+#define Int_DParDEn	       0x00000100 /* 1:Data Parity Error Enable	     */
+#define Int_EarNotEn	       0x00000080 /* 1:Early Notify Enable	     */
+#define Int_DParErrEn	       0x00000040 /* 1:Detected Parity Error Enable  */
+#define Int_SSysErrEn	       0x00000020 /* 1:Signalled System Error Enable */
+#define Int_RMasAbtEn	       0x00000010 /* 1:Received Master Abort Enable  */
+#define Int_RTargAbtEn	       0x00000008 /* 1:Received Target Abort Enable  */
+#define Int_STargAbtEn	       0x00000004 /* 1:Signalled Target Abort Enable */
+#define Int_BLExEn	       0x00000002 /* 1:Buffer List Exhausted Enable  */
+#define Int_FDAExEn	       0x00000001 /* 1:Free Descriptor Area	     */
+					  /*		   Exhausted Enable  */
 
 /* Int_Src bit asign ------------------------------------------------------- */
-#define Int_NRabt              0x00004000 /* 1:Non Recoverable error         */
-#define Int_DmParErrStat       0x00002000 /* 1:DMA Parity Error & Clear      */
-#define Int_BLEx               0x00001000 /* 1:Buffer List Empty & Clear     */
-#define Int_FDAEx              0x00000800 /* 1:FDA Empty & Clear             */
-#define Int_IntNRAbt           0x00000400 /* 1:Non Recoverable Abort         */
-#define	Int_IntCmp             0x00000200 /* 1:MAC control packet complete   */
-#define Int_IntExBD            0x00000100 /* 1:Interrupt Extra BD & Clear    */
-#define Int_DmParErr           0x00000080 /* 1:DMA Parity Error & Clear      */
-#define Int_IntEarNot          0x00000040 /* 1:Receive Data write & Clear    */
-#define Int_SWInt              0x00000020 /* 1:Software request & Clear      */
-#define Int_IntBLEx            0x00000010 /* 1:Buffer List Empty & Clear     */
-#define Int_IntFDAEx           0x00000008 /* 1:FDA Empty & Clear             */
-#define Int_IntPCI             0x00000004 /* 1:PCI controller & Clear        */
-#define Int_IntMacRx           0x00000002 /* 1:Rx controller & Clear         */
-#define Int_IntMacTx           0x00000001 /* 1:Tx controller & Clear         */
+#define Int_NRabt	       0x00004000 /* 1:Non Recoverable error	     */
+#define Int_DmParErrStat       0x00002000 /* 1:DMA Parity Error & Clear	     */
+#define Int_BLEx	       0x00001000 /* 1:Buffer List Empty & Clear     */
+#define Int_FDAEx	       0x00000800 /* 1:FDA Empty & Clear	     */
+#define Int_IntNRAbt	       0x00000400 /* 1:Non Recoverable Abort	     */
+#define Int_IntCmp	       0x00000200 /* 1:MAC control packet complete   */
+#define Int_IntExBD	       0x00000100 /* 1:Interrupt Extra BD & Clear    */
+#define Int_DmParErr	       0x00000080 /* 1:DMA Parity Error & Clear	     */
+#define Int_IntEarNot	       0x00000040 /* 1:Receive Data write & Clear    */
+#define Int_SWInt	       0x00000020 /* 1:Software request & Clear	     */
+#define Int_IntBLEx	       0x00000010 /* 1:Buffer List Empty & Clear     */
+#define Int_IntFDAEx	       0x00000008 /* 1:FDA Empty & Clear	     */
+#define Int_IntPCI	       0x00000004 /* 1:PCI controller & Clear	     */
+#define Int_IntMacRx	       0x00000002 /* 1:Rx controller & Clear	     */
+#define Int_IntMacTx	       0x00000001 /* 1:Tx controller & Clear	     */
 
 /* MD_CA bit asign --------------------------------------------------------- */
-#define MD_CA_PreSup           0x00001000 /* 1:Preamble Supress              */
-#define MD_CA_Busy             0x00000800 /* 1:Busy (Start Operation)        */
-#define MD_CA_Wr               0x00000400 /* 1:Write 0:Read                  */
+#define MD_CA_PreSup	       0x00001000 /* 1:Preamble Supress		     */
+#define MD_CA_Busy	       0x00000800 /* 1:Busy (Start Operation)	     */
+#define MD_CA_Wr	       0x00000400 /* 1:Write 0:Read		     */
 
 
 /*
@@ -306,24 +306,24 @@ struct BDesc {
 #define FD_ALIGN	16
 
 /* Frame Descripter bit asign ---------------------------------------------- */
-#define FD_FDLength_MASK       0x0000FFFF /* Length MASK                     */
-#define FD_BDCnt_MASK          0x001F0000 /* BD count MASK in FD             */
-#define FD_FrmOpt_MASK         0x7C000000 /* Frame option MASK               */
+#define FD_FDLength_MASK       0x0000FFFF /* Length MASK		     */
+#define FD_BDCnt_MASK	       0x001F0000 /* BD count MASK in FD	     */
+#define FD_FrmOpt_MASK	       0x7C000000 /* Frame option MASK		     */
 #define FD_FrmOpt_BigEndian    0x40000000 /* Tx/Rx */
-#define FD_FrmOpt_IntTx        0x20000000 /* Tx only */
-#define FD_FrmOpt_NoCRC        0x10000000 /* Tx only */
+#define FD_FrmOpt_IntTx	       0x20000000 /* Tx only */
+#define FD_FrmOpt_NoCRC	       0x10000000 /* Tx only */
 #define FD_FrmOpt_NoPadding    0x08000000 /* Tx only */
 #define FD_FrmOpt_Packing      0x04000000 /* Rx only */
-#define FD_CownsFD             0x80000000 /* FD Controller owner bit         */
-#define FD_Next_EOL            0x00000001 /* FD EOL indicator                */
-#define FD_BDCnt_SHIFT         16
+#define FD_CownsFD	       0x80000000 /* FD Controller owner bit	     */
+#define FD_Next_EOL	       0x00000001 /* FD EOL indicator		     */
+#define FD_BDCnt_SHIFT	       16
 
 /* Buffer Descripter bit asign --------------------------------------------- */
-#define BD_BuffLength_MASK     0x0000FFFF /* Recieve Data Size               */
-#define BD_RxBDID_MASK         0x00FF0000 /* BD ID Number MASK               */
-#define BD_RxBDSeqN_MASK       0x7F000000 /* Rx BD Sequence Number           */
-#define BD_CownsBD             0x80000000 /* BD Controller owner bit         */
-#define BD_RxBDID_SHIFT        16
+#define BD_BuffLength_MASK     0x0000FFFF /* Recieve Data Size		     */
+#define BD_RxBDID_MASK	       0x00FF0000 /* BD ID Number MASK		     */
+#define BD_RxBDSeqN_MASK       0x7F000000 /* Rx BD Sequence Number	     */
+#define BD_CownsBD	       0x80000000 /* BD Controller owner bit	     */
+#define BD_RxBDID_SHIFT	       16
 #define BD_RxBDSeqN_SHIFT      24
 
 
@@ -352,8 +352,10 @@ struct BDesc {
 /* Tuning parameters */
 #define DMA_BURST_SIZE	32
 #define TX_THRESHOLD	1024
-#define TX_THRESHOLD_MAX 1536       /* used threshold with packet max byte for low pci transfer ability.*/
-#define TX_THRESHOLD_KEEP_LIMIT 10  /* setting threshold max value when overrun error occured this count. */
+/* used threshold with packet max byte for low pci transfer ability.*/
+#define TX_THRESHOLD_MAX 1536
+/* setting threshold max value when overrun error occured this count. */
+#define TX_THRESHOLD_KEEP_LIMIT 10
 
 /* 16 + RX_BUF_NUM * 8 + RX_FD_NUM * 16 + TX_FD_NUM * 32 <= PAGE_SIZE*FD_PAGE_NUM */
 #ifdef TC35815_USE_PACKEDBUFFER
@@ -412,7 +414,7 @@ struct tc35815_local {
 		int max_tx_qlen;
 		int tx_ints;
 		int rx_ints;
-	        int tx_underrun;
+		int tx_underrun;
 	} lstats;
 
 	/* Tx control lock.  This protects the transmit buffer ring
@@ -441,7 +443,7 @@ struct tc35815_local {
 	 *	RX_BUF_NUM BD in Free Buffer FD.
 	 *	One Free Buffer BD has ETH_FRAME_LEN data buffer.
 	 */
-	void * fd_buf;	/* for TxFD, RxFD, FrFD */
+	void *fd_buf;	/* for TxFD, RxFD, FrFD */
 	dma_addr_t fd_buf_dma;
 	struct TxFD *tfd_base;
 	unsigned int tfd_start;
@@ -452,7 +454,7 @@ struct tc35815_local {
 	struct FrFD *fbl_ptr;
 #ifdef TC35815_USE_PACKEDBUFFER
 	unsigned char fbl_curid;
-	void * data_buf[RX_BUF_NUM];		/* packing */
+	void *data_buf[RX_BUF_NUM];		/* packing */
 	dma_addr_t data_buf_dma[RX_BUF_NUM];
 	struct {
 		struct sk_buff *skb;
@@ -493,13 +495,14 @@ static inline void *rxbuf_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
 }
 
 #define TC35815_DMA_SYNC_ONDEMAND
-static void* alloc_rxbuf_page(struct pci_dev *hwdev, dma_addr_t *dma_handle)
+static void *alloc_rxbuf_page(struct pci_dev *hwdev, dma_addr_t *dma_handle)
 {
 #ifdef TC35815_DMA_SYNC_ONDEMAND
 	void *buf;
 	/* pci_map + pci_dma_sync will be more effective than
 	 * pci_alloc_consistent on some archs. */
-	if ((buf = (void *)__get_free_page(GFP_ATOMIC)) == NULL)
+	buf = (void *)__get_free_page(GFP_ATOMIC);
+	if (!buf)
 		return NULL;
 	*dma_handle = pci_map_single(hwdev, buf, PAGE_SIZE,
 				     PCI_DMA_FROMDEVICE);
@@ -564,7 +567,7 @@ static void	tc35815_txdone(struct net_device *dev);
 static int	tc35815_close(struct net_device *dev);
 static struct	net_device_stats *tc35815_get_stats(struct net_device *dev);
 static void	tc35815_set_multicast_list(struct net_device *dev);
-static void     tc35815_tx_timeout(struct net_device *dev);
+static void	tc35815_tx_timeout(struct net_device *dev);
 static int	tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void	tc35815_poll_controller(struct net_device *dev);
@@ -572,8 +575,8 @@ static void	tc35815_poll_controller(struct net_device *dev);
 static const struct ethtool_ops tc35815_ethtool_ops;
 
 /* Example routines you must write ;->. */
-static void 	tc35815_chip_reset(struct net_device *dev);
-static void 	tc35815_chip_init(struct net_device *dev);
+static void	tc35815_chip_reset(struct net_device *dev);
+static void	tc35815_chip_init(struct net_device *dev);
 
 #ifdef DEBUG
 static void	panic_queues(struct net_device *dev);
@@ -821,7 +824,7 @@ static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
 }
 #endif
 
-static int __devinit tc35815_init_dev_addr (struct net_device *dev)
+static int __devinit tc35815_init_dev_addr(struct net_device *dev)
 {
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
@@ -843,8 +846,8 @@ static int __devinit tc35815_init_dev_addr (struct net_device *dev)
 	return 0;
 }
 
-static int __devinit tc35815_init_one (struct pci_dev *pdev,
-				       const struct pci_device_id *ent)
+static int __devinit tc35815_init_one(struct pci_dev *pdev,
+				      const struct pci_device_id *ent)
 {
 	void __iomem *ioaddr = NULL;
 	struct net_device *dev;
@@ -866,7 +869,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	}
 
 	/* dev zeroed in alloc_etherdev */
-	dev = alloc_etherdev (sizeof (*lp));
+	dev = alloc_etherdev(sizeof(*lp));
 	if (dev == NULL) {
 		dev_err(&pdev->dev, "unable to alloc new ethernet\n");
 		return -ENOMEM;
@@ -903,7 +906,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 #endif
 
 	dev->irq = pdev->irq;
-	dev->base_addr = (unsigned long) ioaddr;
+	dev->base_addr = (unsigned long)ioaddr;
 
 	INIT_WORK(&lp->restart_work, tc35815_restart_work);
 	spin_lock_init(&lp->lock);
@@ -922,7 +925,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 		random_ether_addr(dev->dev_addr);
 	}
 
-	rc = register_netdev (dev);
+	rc = register_netdev(dev);
 	if (rc)
 		goto err_out;
 
@@ -943,23 +946,22 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 err_out_unregister:
 	unregister_netdev(dev);
 err_out:
-	free_netdev (dev);
+	free_netdev(dev);
 	return rc;
 }
 
 
-static void __devexit tc35815_remove_one (struct pci_dev *pdev)
+static void __devexit tc35815_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tc35815_local *lp = netdev_priv(dev);
 
 	phy_disconnect(lp->phy_dev);
 	mdiobus_unregister(&lp->mii_bus);
 	kfree(lp->mii_bus.irq);
-	unregister_netdev (dev);
-	free_netdev (dev);
-
-	pci_set_drvdata (pdev, NULL);
+	unregister_netdev(dev);
+	free_netdev(dev);
+	pci_set_drvdata(pdev, NULL);
 }
 
 static int
@@ -976,11 +978,17 @@ tc35815_init_queues(struct net_device *dev)
 		       sizeof(struct TxFD) * TX_FD_NUM >
 		       PAGE_SIZE * FD_PAGE_NUM);
 
-		if ((lp->fd_buf = pci_alloc_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM, &lp->fd_buf_dma)) == 0)
+		lp->fd_buf = pci_alloc_consistent(lp->pci_dev,
+						  PAGE_SIZE * FD_PAGE_NUM,
+						  &lp->fd_buf_dma);
+		if (!lp->fd_buf)
 			return -ENOMEM;
 		for (i = 0; i < RX_BUF_NUM; i++) {
 #ifdef TC35815_USE_PACKEDBUFFER
-			if ((lp->data_buf[i] = alloc_rxbuf_page(lp->pci_dev, &lp->data_buf_dma[i])) == NULL) {
+			lp->data_buf[i] =
+				alloc_rxbuf_page(lp->pci_dev,
+						 &lp->data_buf_dma[i]);
+			if (!lp->data_buf[i]) {
 				while (--i >= 0) {
 					free_rxbuf_page(lp->pci_dev,
 							lp->data_buf[i],
@@ -1023,18 +1031,17 @@ tc35815_init_queues(struct net_device *dev)
 #endif
 		printk("\n");
 	} else {
-		for (i = 0; i < FD_PAGE_NUM; i++) {
-			clear_page((void *)((unsigned long)lp->fd_buf + i * PAGE_SIZE));
-		}
+		for (i = 0; i < FD_PAGE_NUM; i++)
+			clear_page((void *)((unsigned long)lp->fd_buf +
+					    i * PAGE_SIZE));
 	}
 	fd_addr = (unsigned long)lp->fd_buf;
 
 	/* Free Descriptors (for Receive) */
 	lp->rfd_base = (struct RxFD *)fd_addr;
 	fd_addr += sizeof(struct RxFD) * RX_FD_NUM;
-	for (i = 0; i < RX_FD_NUM; i++) {
+	for (i = 0; i < RX_FD_NUM; i++)
 		lp->rfd_base[i].fd.FDCtl = cpu_to_le32(FD_CownsFD);
-	}
 	lp->rfd_cur = lp->rfd_base;
 	lp->rfd_limit = (struct RxFD *)fd_addr - (RX_FD_RESERVE + 1);
 
@@ -1214,7 +1221,7 @@ dump_rxfd(struct RxFD *fd)
 	       le32_to_cpu(fd->fd.FDStat),
 	       le32_to_cpu(fd->fd.FDCtl));
 	if (le32_to_cpu(fd->fd.FDCtl) & FD_CownsFD)
-	    return 0;
+		return 0;
 	printk("BD: ");
 	for (i = 0; i < bd_count; i++)
 		printk(" %08x %08x",
@@ -1363,9 +1370,9 @@ tc35815_open(struct net_device *dev)
 	 * This is used if the interrupt line can turned off (shared).
 	 * See 3c503.c for an example of selecting the IRQ at config-time.
 	 */
-	if (request_irq(dev->irq, &tc35815_interrupt, IRQF_SHARED, dev->name, dev)) {
+	if (request_irq(dev->irq, &tc35815_interrupt, IRQF_SHARED,
+			dev->name, dev))
 		return -EAGAIN;
-	}
 
 	tc35815_chip_reset(dev);
 
@@ -2049,7 +2056,7 @@ tc35815_txdone(struct net_device *dev)
 				struct tc35815_regs __iomem *tr =
 					(struct tc35815_regs __iomem *)dev->base_addr;
 				int head = (lp->tfd_start + TX_FD_NUM - 1) % TX_FD_NUM;
-				struct TxFD* txhead = &lp->tfd_base[head];
+				struct TxFD *txhead = &lp->tfd_base[head];
 				int qlen = (lp->tfd_start + TX_FD_NUM
 					    - lp->tfd_end) % TX_FD_NUM;
 
@@ -2084,7 +2091,7 @@ tc35815_txdone(struct net_device *dev)
 	 * condition, and space has now been made available,
 	 * wake up the queue.
 	 */
-	if (netif_queue_stopped(dev) && ! tc35815_tx_full(dev))
+	if (netif_queue_stopped(dev) && !tc35815_tx_full(dev))
 		netif_wake_queue(dev);
 }
 
@@ -2181,8 +2188,7 @@ tc35815_set_multicast_list(struct net_device *dev)
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 
-	if (dev->flags&IFF_PROMISC)
-	{
+	if (dev->flags & IFF_PROMISC) {
 #ifdef WORKAROUND_100HALF_PROMISC
 		/* With some (all?) 100MHalf HUB, controller will hang
 		 * if we enabled promiscuous mode before linkup... */
@@ -2193,16 +2199,13 @@ tc35815_set_multicast_list(struct net_device *dev)
 #endif
 		/* Enable promiscuous mode */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc | CAM_StationAcc, &tr->CAM_Ctl);
-	}
-	else if((dev->flags&IFF_ALLMULTI) || dev->mc_count > CAM_ENTRY_MAX - 3)
-	{
+	} else if ((dev->flags & IFF_ALLMULTI) ||
+		  dev->mc_count > CAM_ENTRY_MAX - 3) {
 		/* CAM 0, 1, 20 are reserved. */
 		/* Disable promiscuous mode, use normal mode. */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc, &tr->CAM_Ctl);
-	}
-	else if(dev->mc_count)
-	{
-		struct dev_mc_list* cur_addr = dev->mc_list;
+	} else if (dev->mc_count) {
+		struct dev_mc_list *cur_addr = dev->mc_list;
 		int i;
 		int ena_bits = CAM_Ena_Bit(CAM_ENTRY_SOURCE);
 
@@ -2217,8 +2220,7 @@ tc35815_set_multicast_list(struct net_device *dev)
 		}
 		tc_writel(ena_bits, &tr->CAM_Ena);
 		tc_writel(CAM_CompEn | CAM_BroadAcc, &tr->CAM_Ctl);
-	}
-	else {
+	} else {
 		tc_writel(CAM_Ena_Bit(CAM_ENTRY_SOURCE), &tr->CAM_Ena);
 		tc_writel(CAM_CompEn | CAM_BroadAcc, &tr->CAM_Ctl);
 	}
