From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/2] net/macb: Adding comments to various #defs to make
 interpretation easier
Date: Wed, 14 Jan 2015 16:10:50 +0100
Message-ID: <54B686FA.2060001@atmel.com>
References: <1421187351-27279-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jaeden.amero@ni.com>, <rich.tollerton@ni.com>,
	<ben.shelton@ni.com>, <brad.mouring@ni.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Xander Huff <xander.huff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421187351-27279-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/01/2015 23:15, Xander Huff a =E9crit :
> This change is to help improve at-a-glace knowledge of the purpose of=
 the
> various Cadence MACB/GEM registers. Comments are more helpful for hum=
an
> readability than short acronyms.
>=20
> Describe various #define varibles Cadence MACB/GEM registers as docum=
ented
> in Xilinix's "Zynq-7000 All Programmable SoC TechnicalReference Manua=
l, v1.9.1
> (UG-585)"
>=20
> Signed-off-by: Xander Huff <xander.huff@ni.com>

=46or the record:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.h | 269 ++++++++++++++++++++++----=
----------
>  1 file changed, 162 insertions(+), 107 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethern=
et/cadence/macb.h
> index 084191b..8e8c3c9 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -15,20 +15,20 @@
>  #define MACB_MAX_QUEUES 8
> =20
>  /* MACB register offsets */
> -#define MACB_NCR				0x0000
> -#define MACB_NCFGR				0x0004
> -#define MACB_NSR				0x0008
> +#define MACB_NCR				0x0000 /* Network Control */
> +#define MACB_NCFGR				0x0004 /* Network Config */
> +#define MACB_NSR				0x0008 /* Network Status */
>  #define MACB_TAR				0x000c /* AT91RM9200 only */
>  #define MACB_TCR				0x0010 /* AT91RM9200 only */
> -#define MACB_TSR				0x0014
> -#define MACB_RBQP				0x0018
> -#define MACB_TBQP				0x001c
> -#define MACB_RSR				0x0020
> -#define MACB_ISR				0x0024
> -#define MACB_IER				0x0028
> -#define MACB_IDR				0x002c
> -#define MACB_IMR				0x0030
> -#define MACB_MAN				0x0034
> +#define MACB_TSR				0x0014 /* Transmit Status */
> +#define MACB_RBQP				0x0018 /* RX Q Base Address */
> +#define MACB_TBQP				0x001c /* TX Q Base Address */
> +#define MACB_RSR				0x0020 /* Receive Status */
> +#define MACB_ISR				0x0024 /* Interrupt Status */
> +#define MACB_IER				0x0028 /* Interrupt Enable */
> +#define MACB_IDR				0x002c /* Interrupt Disable */
> +#define MACB_IMR				0x0030 /* Interrupt Mask */
> +#define MACB_MAN				0x0034 /* PHY Maintenance */
>  #define MACB_PTR				0x0038
>  #define MACB_PFR				0x003c
>  #define MACB_FTO				0x0040
> @@ -68,27 +68,27 @@
>  #define MACB_MID				0x00fc
> =20
>  /* GEM register offsets. */
> -#define GEM_NCFGR				0x0004
> -#define GEM_USRIO				0x000c
> -#define GEM_DMACFG				0x0010
> -#define GEM_HRB					0x0080
> -#define GEM_HRT					0x0084
> -#define GEM_SA1B				0x0088
> -#define GEM_SA1T				0x008C
> -#define GEM_SA2B				0x0090
> -#define GEM_SA2T				0x0094
> -#define GEM_SA3B				0x0098
> -#define GEM_SA3T				0x009C
> -#define GEM_SA4B				0x00A0
> -#define GEM_SA4T				0x00A4
> -#define GEM_OTX					0x0100
> -#define GEM_DCFG1				0x0280
> -#define GEM_DCFG2				0x0284
> -#define GEM_DCFG3				0x0288
> -#define GEM_DCFG4				0x028c
> -#define GEM_DCFG5				0x0290
> -#define GEM_DCFG6				0x0294
> -#define GEM_DCFG7				0x0298
> +#define GEM_NCFGR				0x0004 /* Network Config */
> +#define GEM_USRIO				0x000c /* User IO */
> +#define GEM_DMACFG				0x0010 /* DMA Configuration */
> +#define GEM_HRB					0x0080 /* Hash Bottom */
> +#define GEM_HRT					0x0084 /* Hash Top */
> +#define GEM_SA1B				0x0088 /* Specific1 Bottom */
> +#define GEM_SA1T				0x008C /* Specific1 Top */
> +#define GEM_SA2B				0x0090 /* Specific2 Bottom */
> +#define GEM_SA2T				0x0094 /* Specific2 Top */
> +#define GEM_SA3B				0x0098 /* Specific3 Bottom */
> +#define GEM_SA3T				0x009C /* Specific3 Top */
> +#define GEM_SA4B				0x00A0 /* Specific4 Bottom */
> +#define GEM_SA4T				0x00A4 /* Specific4 Top */
> +#define GEM_OTX					0x0100 /* Octets transmitted */
> +#define GEM_DCFG1				0x0280 /* Design Config 1 */
> +#define GEM_DCFG2				0x0284 /* Design Config 2 */
> +#define GEM_DCFG3				0x0288 /* Design Config 3 */
> +#define GEM_DCFG4				0x028c /* Design Config 4 */
> +#define GEM_DCFG5				0x0290 /* Design Config 5 */
> +#define GEM_DCFG6				0x0294 /* Design Config 6 */
> +#define GEM_DCFG7				0x0298 /* Design Config 7 */
> =20
>  #define GEM_ISR(hw_q)				(0x0400 + ((hw_q) << 2))
>  #define GEM_TBQP(hw_q)				(0x0440 + ((hw_q) << 2))
> @@ -98,67 +98,73 @@
>  #define GEM_IMR(hw_q)				(0x0640 + ((hw_q) << 2))
> =20
>  /* Bitfields in NCR */
> -#define MACB_LB_OFFSET				0
> +#define MACB_LB_OFFSET				0 /* reserved */
>  #define MACB_LB_SIZE				1
> -#define MACB_LLB_OFFSET				1
> +#define MACB_LLB_OFFSET				1 /* Loop back local */
>  #define MACB_LLB_SIZE				1
> -#define MACB_RE_OFFSET				2
> +#define MACB_RE_OFFSET				2 /* Receive enable */
>  #define MACB_RE_SIZE				1
> -#define MACB_TE_OFFSET				3
> +#define MACB_TE_OFFSET				3 /* Transmit enable */
>  #define MACB_TE_SIZE				1
> -#define MACB_MPE_OFFSET				4
> +#define MACB_MPE_OFFSET				4 /* Management port enable */
>  #define MACB_MPE_SIZE				1
> -#define MACB_CLRSTAT_OFFSET			5
> +#define MACB_CLRSTAT_OFFSET			5 /* Clear stats regs */
>  #define MACB_CLRSTAT_SIZE			1
> -#define MACB_INCSTAT_OFFSET			6
> +#define MACB_INCSTAT_OFFSET			6 /* Incremental stats regs */
>  #define MACB_INCSTAT_SIZE			1
> -#define MACB_WESTAT_OFFSET			7
> +#define MACB_WESTAT_OFFSET			7 /* Write enable stats regs */
>  #define MACB_WESTAT_SIZE			1
> -#define MACB_BP_OFFSET				8
> +#define MACB_BP_OFFSET				8 /* Back pressure */
>  #define MACB_BP_SIZE				1
> -#define MACB_TSTART_OFFSET			9
> +#define MACB_TSTART_OFFSET			9 /* Start transmission */
>  #define MACB_TSTART_SIZE			1
> -#define MACB_THALT_OFFSET			10
> +#define MACB_THALT_OFFSET			10 /* Transmit halt */
>  #define MACB_THALT_SIZE				1
> -#define MACB_NCR_TPF_OFFSET			11
> +#define MACB_NCR_TPF_OFFSET			11 /* Transmit pause frame */
>  #define MACB_NCR_TPF_SIZE			1
> -#define MACB_TZQ_OFFSET				12
> +#define MACB_TZQ_OFFSET				12 /* Transmit zero quantum
> +						    * pause frame
> +						    */
>  #define MACB_TZQ_SIZE				1
> =20
>  /* Bitfields in NCFGR */
> -#define MACB_SPD_OFFSET				0
> +#define MACB_SPD_OFFSET				0 /* Speed */
>  #define MACB_SPD_SIZE				1
> -#define MACB_FD_OFFSET				1
> +#define MACB_FD_OFFSET				1 /* Full duplex */
>  #define MACB_FD_SIZE				1
> -#define MACB_BIT_RATE_OFFSET			2
> +#define MACB_BIT_RATE_OFFSET			2 /* Discard non-VLAN frames */
>  #define MACB_BIT_RATE_SIZE			1
> -#define MACB_JFRAME_OFFSET			3
> +#define MACB_JFRAME_OFFSET			3 /* reserved */
>  #define MACB_JFRAME_SIZE			1
> -#define MACB_CAF_OFFSET				4
> +#define MACB_CAF_OFFSET				4 /* Copy all frames */
>  #define MACB_CAF_SIZE				1
> -#define MACB_NBC_OFFSET				5
> +#define MACB_NBC_OFFSET				5 /* No broadcast */
>  #define MACB_NBC_SIZE				1
> -#define MACB_NCFGR_MTI_OFFSET			6
> +#define MACB_NCFGR_MTI_OFFSET			6 /* Multicast hash enable */
>  #define MACB_NCFGR_MTI_SIZE			1
> -#define MACB_UNI_OFFSET				7
> +#define MACB_UNI_OFFSET				7 /* Unicast hash enable */
>  #define MACB_UNI_SIZE				1
> -#define MACB_BIG_OFFSET				8
> +#define MACB_BIG_OFFSET				8 /* Receive 1536 byte frames */
>  #define MACB_BIG_SIZE				1
> -#define MACB_EAE_OFFSET				9
> +#define MACB_EAE_OFFSET				9 /* External address match
> +						   * enable
> +						   */
>  #define MACB_EAE_SIZE				1
>  #define MACB_CLK_OFFSET				10
>  #define MACB_CLK_SIZE				2
> -#define MACB_RTY_OFFSET				12
> +#define MACB_RTY_OFFSET				12 /* Retry test */
>  #define MACB_RTY_SIZE				1
> -#define MACB_PAE_OFFSET				13
> +#define MACB_PAE_OFFSET				13 /* Pause enable */
>  #define MACB_PAE_SIZE				1
>  #define MACB_RM9200_RMII_OFFSET			13 /* AT91RM9200 only */
>  #define MACB_RM9200_RMII_SIZE			1  /* AT91RM9200 only */
> -#define MACB_RBOF_OFFSET			14
> +#define MACB_RBOF_OFFSET			14 /* Receive buffer offset */
>  #define MACB_RBOF_SIZE				2
> -#define MACB_RLCE_OFFSET			16
> +#define MACB_RLCE_OFFSET			16 /* Length field error frame
> +						    * discard
> +						    */
>  #define MACB_RLCE_SIZE				1
> -#define MACB_DRFCS_OFFSET			17
> +#define MACB_DRFCS_OFFSET			17 /* FCS remove */
>  #define MACB_DRFCS_SIZE				1
>  #define MACB_EFRHD_OFFSET			18
>  #define MACB_EFRHD_SIZE				1
> @@ -166,111 +172,160 @@
>  #define MACB_IRXFCS_SIZE			1
> =20
>  /* GEM specific NCFGR bitfields. */
> -#define GEM_GBE_OFFSET				10
> +#define GEM_GBE_OFFSET				10 /* Gigabit mode enable */
>  #define GEM_GBE_SIZE				1
> -#define GEM_CLK_OFFSET				18
> +#define GEM_CLK_OFFSET				18 /* MDC clock division */
>  #define GEM_CLK_SIZE				3
> -#define GEM_DBW_OFFSET				21
> +#define GEM_DBW_OFFSET				21 /* Data bus width */
>  #define GEM_DBW_SIZE				2
>  #define GEM_RXCOEN_OFFSET			24
>  #define GEM_RXCOEN_SIZE				1
> =20
>  /* Constants for data bus width. */
> -#define GEM_DBW32				0
> -#define GEM_DBW64				1
> -#define GEM_DBW128				2
> +#define GEM_DBW32				0 /* 32 bit AMBA AHB data bus
> +						   * width
> +						   */
> +#define GEM_DBW64				1 /* 64 bit AMBA AHB data bus
> +						   * width
> +						   */
> +#define GEM_DBW128				2 /* 128 bit AMBA AHB data bus
> +						   * width
> +						   */
> =20
>  /* Bitfields in DMACFG. */
> -#define GEM_FBLDO_OFFSET			0
> +#define GEM_FBLDO_OFFSET			0 /* AHB fixed burst length for
> +						   * DMA data operations
> +						   */
>  #define GEM_FBLDO_SIZE				5
> -#define GEM_ENDIA_OFFSET			7
> +#define GEM_ENDIA_OFFSET			7 /* AHB endian swap mode enable
> +						   * for packet data accesses
> +						   */
>  #define GEM_ENDIA_SIZE				1
> -#define GEM_RXBMS_OFFSET			8
> +#define GEM_RXBMS_OFFSET			8 /* Receiver packet buffer
> +						   * memory size select
> +						   */
>  #define GEM_RXBMS_SIZE				2
> -#define GEM_TXPBMS_OFFSET			10
> +#define GEM_TXPBMS_OFFSET			10 /* Transmitter packet buffer
> +						    * memory size select
> +						    */
>  #define GEM_TXPBMS_SIZE				1
> -#define GEM_TXCOEN_OFFSET			11
> +#define GEM_TXCOEN_OFFSET			11 /* Transmitter IP, TCP and
> +						    * UDP checksum generation
> +						    * offload enable
> +						    */
>  #define GEM_TXCOEN_SIZE				1
> -#define GEM_RXBS_OFFSET				16
> +#define GEM_RXBS_OFFSET				16 /* DMA receive buffer size in
> +						    * AHB system memory
> +						    */
>  #define GEM_RXBS_SIZE				8
> -#define GEM_DDRP_OFFSET				24
> +#define GEM_DDRP_OFFSET				24 /* disc_when_no_ahb */
>  #define GEM_DDRP_SIZE				1
> =20
> =20
>  /* Bitfields in NSR */
> -#define MACB_NSR_LINK_OFFSET			0
> +#define MACB_NSR_LINK_OFFSET			0 /* pcs_link_state */
>  #define MACB_NSR_LINK_SIZE			1
> -#define MACB_MDIO_OFFSET			1
> +#define MACB_MDIO_OFFSET			1 /* status of the mdio_in
> +						   * pin
> +						   */
>  #define MACB_MDIO_SIZE				1
> -#define MACB_IDLE_OFFSET			2
> +#define MACB_IDLE_OFFSET			2 /* The PHY management logic is
> +						   * idle (i.e. has completed)
> +						   */
>  #define MACB_IDLE_SIZE				1
> =20
>  /* Bitfields in TSR */
> -#define MACB_UBR_OFFSET				0
> +#define MACB_UBR_OFFSET				0 /* Used bit read */
>  #define MACB_UBR_SIZE				1
> -#define MACB_COL_OFFSET				1
> +#define MACB_COL_OFFSET				1 /* Collision occurred */
>  #define MACB_COL_SIZE				1
> -#define MACB_TSR_RLE_OFFSET			2
> +#define MACB_TSR_RLE_OFFSET			2 /* Retry limit exceeded */
>  #define MACB_TSR_RLE_SIZE			1
> -#define MACB_TGO_OFFSET				3
> +#define MACB_TGO_OFFSET				3 /* Transmit go */
>  #define MACB_TGO_SIZE				1
> -#define MACB_BEX_OFFSET				4
> +#define MACB_BEX_OFFSET				4 /* Transmit frame corruption
> +						   * due to AHB error
> +						   */
>  #define MACB_BEX_SIZE				1
>  #define MACB_RM9200_BNQ_OFFSET			4 /* AT91RM9200 only */
>  #define MACB_RM9200_BNQ_SIZE			1 /* AT91RM9200 only */
> -#define MACB_COMP_OFFSET			5
> +#define MACB_COMP_OFFSET			5 /* Trnasmit complete */
>  #define MACB_COMP_SIZE				1
> -#define MACB_UND_OFFSET				6
> +#define MACB_UND_OFFSET				6 /* Trnasmit under run */
>  #define MACB_UND_SIZE				1
> =20
>  /* Bitfields in RSR */
> -#define MACB_BNA_OFFSET				0
> +#define MACB_BNA_OFFSET				0 /* Buffer not available */
>  #define MACB_BNA_SIZE				1
> -#define MACB_REC_OFFSET				1
> +#define MACB_REC_OFFSET				1 /* Frame received */
>  #define MACB_REC_SIZE				1
> -#define MACB_OVR_OFFSET				2
> +#define MACB_OVR_OFFSET				2 /* Receive overrun */
>  #define MACB_OVR_SIZE				1
> =20
>  /* Bitfields in ISR/IER/IDR/IMR */
> -#define MACB_MFD_OFFSET				0
> +#define MACB_MFD_OFFSET				0 /* Management frame sent */
>  #define MACB_MFD_SIZE				1
> -#define MACB_RCOMP_OFFSET			1
> +#define MACB_RCOMP_OFFSET			1 /* Receive complete */
>  #define MACB_RCOMP_SIZE				1
> -#define MACB_RXUBR_OFFSET			2
> +#define MACB_RXUBR_OFFSET			2 /* RX used bit read */
>  #define MACB_RXUBR_SIZE				1
> -#define MACB_TXUBR_OFFSET			3
> +#define MACB_TXUBR_OFFSET			3 /* TX used bit read */
>  #define MACB_TXUBR_SIZE				1
> -#define MACB_ISR_TUND_OFFSET			4
> +#define MACB_ISR_TUND_OFFSET			4 /* Enable trnasmit buffer
> +						   * under run interrupt
> +						   */
>  #define MACB_ISR_TUND_SIZE			1
> -#define MACB_ISR_RLE_OFFSET			5
> +#define MACB_ISR_RLE_OFFSET			5 /* Enable retry limit exceeded
> +						   * or late collision interrupt
> +						   */
>  #define MACB_ISR_RLE_SIZE			1
> -#define MACB_TXERR_OFFSET			6
> +#define MACB_TXERR_OFFSET			6 /* Enable transmit frame
> +						   * corruption due to AHB error
> +						   * interrupt
> +						   */
>  #define MACB_TXERR_SIZE				1
> -#define MACB_TCOMP_OFFSET			7
> +#define MACB_TCOMP_OFFSET			7 /* Enable transmit complete
> +						   * interrupt
> +						   */
>  #define MACB_TCOMP_SIZE				1
> -#define MACB_ISR_LINK_OFFSET			9
> +#define MACB_ISR_LINK_OFFSET			9 /* Enable link change
> +						   * interrupt
> +						   */
>  #define MACB_ISR_LINK_SIZE			1
> -#define MACB_ISR_ROVR_OFFSET			10
> +#define MACB_ISR_ROVR_OFFSET			10 /* Enable receive overrun
> +						    * interrupt
> +						    */
>  #define MACB_ISR_ROVR_SIZE			1
> -#define MACB_HRESP_OFFSET			11
> +#define MACB_HRESP_OFFSET			11 /* Enable hrsep not OK
> +						    * interrupt
> +						    */
>  #define MACB_HRESP_SIZE				1
> -#define MACB_PFR_OFFSET				12
> +#define MACB_PFR_OFFSET				12 /* Enable pause frame with
> +						    * non-zero pause quantum
> +						    * interrupt
> +						    */
>  #define MACB_PFR_SIZE				1
> -#define MACB_PTZ_OFFSET				13
> +#define MACB_PTZ_OFFSET				13 /* Enable pause time zero
> +						    * interrupt
> +						    */
>  #define MACB_PTZ_SIZE				1
> =20
>  /* Bitfields in MAN */
> -#define MACB_DATA_OFFSET			0
> +#define MACB_DATA_OFFSET			0 /* data */
>  #define MACB_DATA_SIZE				16
> -#define MACB_CODE_OFFSET			16
> +#define MACB_CODE_OFFSET			16 /* Must be written to 10 */
>  #define MACB_CODE_SIZE				2
> -#define MACB_REGA_OFFSET			18
> +#define MACB_REGA_OFFSET			18 /* Register address */
>  #define MACB_REGA_SIZE				5
> -#define MACB_PHYA_OFFSET			23
> +#define MACB_PHYA_OFFSET			23 /* PHY address */
>  #define MACB_PHYA_SIZE				5
> -#define MACB_RW_OFFSET				28
> +#define MACB_RW_OFFSET				28 /* Operation. 10 is read. 01
> +						    * is write.
> +						    */
>  #define MACB_RW_SIZE				2
> -#define MACB_SOF_OFFSET				30
> +#define MACB_SOF_OFFSET				30 /* Must be written to 1 for
> +						    * Clause 22 operation
> +						    */
>  #define MACB_SOF_SIZE				2
> =20
>  /* Bitfields in USRIO (AVR32) */
> @@ -286,7 +341,7 @@
>  /* Bitfields in USRIO (AT91) */
>  #define MACB_RMII_OFFSET			0
>  #define MACB_RMII_SIZE				1
> -#define GEM_RGMII_OFFSET			0	/* GEM gigabit mode */
> +#define GEM_RGMII_OFFSET			0 /* GEM gigabit mode */
>  #define GEM_RGMII_SIZE				1
>  #define MACB_CLKEN_OFFSET			1
>  #define MACB_CLKEN_SIZE				1
>=20


--=20
Nicolas Ferre
