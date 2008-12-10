From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 18/33] drivers/net: Make static
Date: Tue, 9 Dec 2008 16:42:35 -0800
Message-ID: <9929d2390812091642l69fbdc4eke30dcb1d3b95f23b@mail.gmail.com>
References: <493EA286.7080500@gmail.com> <493EC19E.3070404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Roel Kluin" <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.187]:54793 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbYLJAmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 19:42:38 -0500
Received: by rn-out-0910.google.com with SMTP id k40so244276rnd.17
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 16:42:36 -0800 (PST)
In-Reply-To: <493EC19E.3070404@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2008 at 11:06 AM, Roel Kluin <roel.kluin@gmail.com> wrote:
> Sparse asked whether these could be static.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  drivers/net/arcnet/capmode.c                  |    2 +-
>  drivers/net/arcnet/com90xx.c                  |    2 +-
>  drivers/net/atlx/atl1.c                       |    4 ++--
>  drivers/net/cxgb3/vsc8211.c                   |    2 +-
>  drivers/net/irda/ma600-sir.c                  |    2 +-
>  drivers/net/irda/smsc-ircc2.c                 |    6 +++---
>  drivers/net/irda/w83977af_ir.c                |   12 ++++++------
>  drivers/net/ixgbe/ixgbe_82598.c               |   14 +++++++-------
>  drivers/net/plip.c                            |    2 +-
>  drivers/net/qlge/qlge_ethtool.c               |    2 +-
>  drivers/net/qlge/qlge_main.c                  |   14 ++++++++------
>  drivers/net/qlge/qlge_mpi.c                   |    2 +-
>  drivers/net/skfp/skfddi.c                     |    6 +++---
>  drivers/net/tokenring/madgemc.c               |    2 +-
>  drivers/net/tokenring/proteon.c               |    2 +-
>  drivers/net/tokenring/skisa.c                 |    2 +-
>  drivers/net/usb/hso.c                         |    4 ++--
>  drivers/net/wan/sbni.c                        |    4 +---
>  drivers/net/wan/x25_asy.c                     |    2 +-
>  drivers/net/wan/z85230.c                      |    4 ++--
>  drivers/net/wireless/airo.c                   |    2 +-
>  drivers/net/wireless/atmel.c                  |    2 +-
>  drivers/net/wireless/b43/phy_a.c              |    4 ++--
>  drivers/net/wireless/b43/phy_g.c              |   16 ++++++++--------
>  drivers/net/wireless/ipw2100.c                |    6 +++---
>  drivers/net/wireless/prism54/islpci_hotplug.c |   12 ++++--------
>  drivers/net/wireless/ray_cs.c                 |    2 +-
>  27 files changed, 65 insertions(+), 69 deletions(-)
>
> hmm, still a lot. should this be split in drivers/net/* ?
>
> diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
> index 02cb8f1..c7e9b58 100644
> --- a/drivers/net/arcnet/capmode.c
> +++ b/drivers/net/arcnet/capmode.c
> @@ -61,7 +61,7 @@ static struct ArcProto capmode_proto =
>  };
>
>
> -void arcnet_cap_init(void)
> +static void arcnet_cap_init(void)
>  {
>        int count;
>
> diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
> index 0d45553..680a530 100644
> --- a/drivers/net/arcnet/com90xx.c
> +++ b/drivers/net/arcnet/com90xx.c
> @@ -583,7 +583,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
>  *
>  * However, it does make sure the card is in a defined state.
>  */
> -int com90xx_reset(struct net_device *dev, int really_reset)
> +static int com90xx_reset(struct net_device *dev, int really_reset)
>  {
>        struct arcnet_local *lp = dev->priv;
>        short ioaddr = dev->base_addr;
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index aef403d..8f82a8c 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -195,7 +195,7 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt,
>  * value exists, a default value is used.  The final value is stored
>  * in a variable in the adapter structure.
>  */
> -void __devinit atl1_check_options(struct atl1_adapter *adapter)
> +static void __devinit atl1_check_options(struct atl1_adapter *adapter)
>  {
>        struct pci_dev *pdev = adapter->pdev;
>        int bd = adapter->bd_number;
> @@ -523,7 +523,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
>  * Reads the adapter's MAC address from the EEPROM
>  * hw - Struct containing variables accessed by shared code
>  */
> -s32 atl1_read_mac_addr(struct atl1_hw *hw)
> +static s32 atl1_read_mac_addr(struct atl1_hw *hw)
>  {
>        u16 i;
>
> diff --git a/drivers/net/cxgb3/vsc8211.c b/drivers/net/cxgb3/vsc8211.c
> index 33f956b..722034b 100644
> --- a/drivers/net/cxgb3/vsc8211.c
> +++ b/drivers/net/cxgb3/vsc8211.c
> @@ -292,7 +292,7 @@ static int vsc8211_set_automdi(struct cphy *phy, int enable)
>        return 0;
>  }
>
> -int vsc8211_set_speed_duplex(struct cphy *phy, int speed, int duplex)
> +static int vsc8211_set_speed_duplex(struct cphy *phy, int speed, int duplex)
>  {
>        int err;
>
> diff --git a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
> index 1ceed9c..e912164 100644
> --- a/drivers/net/irda/ma600-sir.c
> +++ b/drivers/net/irda/ma600-sir.c
> @@ -236,7 +236,7 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
>  * avoid the state machine complexity before we get things working
>  */
>
> -int ma600_reset(struct sir_dev *dev)
> +static int ma600_reset(struct sir_dev *dev)
>  {
>        IRDA_DEBUG(2, "%s()\n", __func__);
>
> diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
> index b5360fe..5d09e15 100644
> --- a/drivers/net/irda/smsc-ircc2.c
> +++ b/drivers/net/irda/smsc-ircc2.c
> @@ -872,7 +872,7 @@ static void smsc_ircc_timeout(struct net_device *dev)
>  *    waits until the next transmit interrupt, and continues until the
>  *    frame is transmitted.
>  */
> -int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
> +static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
>  {
>        struct smsc_ircc_cb *self;
>        unsigned long flags;
> @@ -1128,7 +1128,7 @@ static void smsc_ircc_change_speed(struct smsc_ircc_cb *self, u32 speed)
>  *    Set speed of IrDA port to specified baudrate
>  *
>  */
> -void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
> +static void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
>  {
>        int iobase;
>        int fcr;    /* FIFO control reg */
> @@ -1894,7 +1894,7 @@ static void __exit smsc_ircc_cleanup(void)
>  * This function *must* be called with spinlock held, because it may
>  * be called from the irq handler (via smsc_ircc_change_speed()). - Jean II
>  */
> -void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
> +static void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
>  {
>        struct net_device *dev;
>        int fir_base, sir_base;
> diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
> index 002a6d7..b3c6768 100644
> --- a/drivers/net/irda/w83977af_ir.c
> +++ b/drivers/net/irda/w83977af_ir.c
> @@ -147,7 +147,7 @@ static void __exit w83977af_cleanup(void)
>  *    Open driver instance
>  *
>  */
> -int w83977af_open(int i, unsigned int iobase, unsigned int irq,
> +static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
>                  unsigned int dma)
>  {
>        struct net_device *dev;
> @@ -310,7 +310,7 @@ static int w83977af_close(struct w83977af_ir *self)
>        return 0;
>  }
>
> -int w83977af_probe( int iobase, int irq, int dma)
> +static int w83977af_probe(int iobase, int irq, int dma)
>  {
>        int version;
>        int i;
> @@ -409,7 +409,7 @@ int w83977af_probe( int iobase, int irq, int dma)
>        return -1;
>  }
>
> -void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
> +static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
>  {
>        int ir_mode = HCR_SIR;
>        int iobase;
> @@ -489,7 +489,7 @@ void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
>  *    Sets up a DMA transfer to send the current frame.
>  *
>  */
> -int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
> +static int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>        struct w83977af_ir *self;
>        __s32 speed;
> @@ -731,7 +731,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
>  *    if it starts to receive a frame.
>  *
>  */
> -int w83977af_dma_receive(struct w83977af_ir *self)
> +static int w83977af_dma_receive(struct w83977af_ir *self)
>  {
>        int iobase;
>        __u8 set;
> @@ -803,7 +803,7 @@ int w83977af_dma_receive(struct w83977af_ir *self)
>  *    Finished with receiving a frame
>  *
>  */
> -int w83977af_dma_receive_complete(struct w83977af_ir *self)
> +static int w83977af_dma_receive_complete(struct w83977af_ir *self)
>  {
>        struct sk_buff *skb;
>        struct st_fifo *st_fifo;
> diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
> index 7cddcfb..0645140 100644
> --- a/drivers/net/ixgbe/ixgbe_82598.c
> +++ b/drivers/net/ixgbe/ixgbe_82598.c
> @@ -146,7 +146,7 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
>  *
>  *  Determines the link capabilities by reading the AUTOC register.
>  **/
> -s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
> +static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
>                                              ixgbe_link_speed *speed,
>                                              bool *autoneg)
>  {
> @@ -205,7 +205,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
>  *  Configures the flow control settings based on SW configuration.  This
>  *  function is used for 802.3x flow control configuration only.
>  **/
> -s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
> +static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
>  {
>        u32 frctl_reg;
>        u32 rmcs_reg;
> @@ -648,7 +648,7 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
>  *  @rar: receive address register index to associate with a VMDq index
>  *  @vmdq: VMDq set index
>  **/
> -s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
> +static s32 ixgbe_set_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
>  {
>        u32 rar_high;
>
> @@ -692,7 +692,7 @@ static s32 ixgbe_clear_vmdq_82598(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
>  *
>  *  Turn on/off specified VLAN in the VLAN filter table.
>  **/
> -s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
> +static s32 ixgbe_set_vfta_82598(struct ixgbe_hw *hw, u32 vlan, u32 vind,
>                          bool vlan_on)
>  {
>        u32 regindex;
> @@ -816,7 +816,7 @@ static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index)
>  *
>  *  Performs read operation to Atlas analog register specified.
>  **/
> -s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
> +static s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
>  {
>        u32  atlas_ctl;
>
> @@ -838,7 +838,7 @@ s32 ixgbe_read_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 *val)
>  *
>  *  Performs write operation to Atlas analog register specified.
>  **/
> -s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
> +static s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
>  {
>        u32  atlas_ctl;
>
> @@ -856,7 +856,7 @@ s32 ixgbe_write_analog_reg8_82598(struct ixgbe_hw *hw, u32 reg, u8 val)
>  *
>  *  Determines physical layer capabilities of the current configuration.
>  **/
> -s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
> +static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
>  {
>        s32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
>
> diff --git a/drivers/net/plip.c b/drivers/net/plip.c
> index 1e96542..9781881 100644
> --- a/drivers/net/plip.c
> +++ b/drivers/net/plip.c
> @@ -1018,7 +1018,7 @@ plip_hard_header(struct sk_buff *skb, struct net_device *dev,
>        return ret;
>  }
>
> -int plip_hard_header_cache(const struct neighbour *neigh,
> +static int plip_hard_header_cache(const struct neighbour *neigh,
>                            struct hh_cache *hh)
>  {
>        int ret;
> diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
> index b62fbd4..eefb81b 100644
> --- a/drivers/net/qlge/qlge_ethtool.c
> +++ b/drivers/net/qlge/qlge_ethtool.c
> @@ -97,7 +97,7 @@ exit:
>        return status;
>  }
>
> -void ql_update_stats(struct ql_adapter *qdev)
> +static void ql_update_stats(struct ql_adapter *qdev)
>  {
>        u32 i;
>        u64 data;
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index b83a9c9..7f9c6a8 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -643,7 +643,7 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
>
>  }
>
> -int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
> +static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
>  {
>        int status = 0;
>        /* wait for reg to come ready */
> @@ -833,7 +833,7 @@ end:
>  }
>
>  /* Get the next large buffer. */
> -struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
> +static struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
>  {
>        struct bq_desc *lbq_desc = &rx_ring->lbq[rx_ring->lbq_curr_idx];
>        rx_ring->lbq_curr_idx++;
> @@ -844,7 +844,7 @@ struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
>  }
>
>  /* Get the next small buffer. */
> -struct bq_desc *ql_get_curr_sbuf(struct rx_ring *rx_ring)
> +static struct bq_desc *ql_get_curr_sbuf(struct rx_ring *rx_ring)
>  {
>        struct bq_desc *sbq_desc = &rx_ring->sbq[rx_ring->sbq_curr_idx];
>        rx_ring->sbq_curr_idx++;
> @@ -1167,7 +1167,7 @@ map_error:
>        return NETDEV_TX_BUSY;
>  }
>
> -void ql_realign_skb(struct sk_buff *skb, int len)
> +static void ql_realign_skb(struct sk_buff *skb, int len)
>  {
>        void *temp_addr = skb->data;
>
> @@ -2071,7 +2071,8 @@ err:
>        return -ENOMEM;
>  }
>
> -void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
> +static void ql_free_lbq_buffers(struct ql_adapter *qdev,
> +               struct rx_ring *rx_ring)
>  {
>        int i;
>        struct bq_desc *lbq_desc;
> @@ -2134,7 +2135,8 @@ mem_error:
>        return -ENOMEM;
>  }
>
> -void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
> +static void ql_free_sbq_buffers(struct ql_adapter *qdev,
> +               struct rx_ring *rx_ring)
>  {
>        int i;
>        struct bq_desc *sbq_desc;
> diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
> index 24fe344..fa31891 100644
> --- a/drivers/net/qlge/qlge_mpi.c
> +++ b/drivers/net/qlge/qlge_mpi.c
> @@ -19,7 +19,7 @@ exit:
>        return status;
>  }
>
> -int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
> +static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
>  {
>        int i, status;
>
> diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
> index a2b092b..9f641f2 100644
> --- a/drivers/net/skfp/skfddi.c
> +++ b/drivers/net/skfp/skfddi.c
> @@ -612,7 +612,7 @@ static int skfp_close(struct net_device *dev)
>  *   Interrupts are disabled, then reenabled at the adapter.
>  */
>
> -irqreturn_t skfp_interrupt(int irq, void *dev_id)
> +static irqreturn_t skfp_interrupt(int irq, void *dev_id)
>  {
>        struct net_device *dev = dev_id;
>        struct s_smc *smc;      /* private board structure pointer */
> @@ -679,7 +679,7 @@ irqreturn_t skfp_interrupt(int irq, void *dev_id)
>  *   independent.
>  *
>  */
> -struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
> +static struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
>  {
>        struct s_smc *bp = netdev_priv(dev);
>
> @@ -1224,7 +1224,7 @@ static void send_queued_packets(struct s_smc *smc)
>  * Verify if the source address is set. Insert it if necessary.
>  *
>  ************************/
> -void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
> +static void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
>  {
>        unsigned char SRBit;
>
> diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
> index c9c5a2b..0d2f58c 100644
> --- a/drivers/net/tokenring/madgemc.c
> +++ b/drivers/net/tokenring/madgemc.c
> @@ -467,7 +467,7 @@ static irqreturn_t madgemc_interrupt(int irq, void *dev_id)
>  * zero to leave the TMS NSELOUT bits unaffected.
>  *
>  */
> -unsigned short madgemc_setnselout_pins(struct net_device *dev)
> +static unsigned short madgemc_setnselout_pins(struct net_device *dev)
>  {
>        unsigned char reg1;
>        struct net_local *tp = netdev_priv(dev);
> diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
> index 00ea945..74c4d6a 100644
> --- a/drivers/net/tokenring/proteon.c
> +++ b/drivers/net/tokenring/proteon.c
> @@ -284,7 +284,7 @@ static void proteon_read_eeprom(struct net_device *dev)
>                dev->dev_addr[i] = proteon_sifreadw(dev, SIFINC) >> 8;
>  }
>
> -unsigned short proteon_setnselout_pins(struct net_device *dev)
> +static unsigned short proteon_setnselout_pins(struct net_device *dev)
>  {
>        return 0;
>  }
> diff --git a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
> index 41b6999..bc39f29 100644
> --- a/drivers/net/tokenring/skisa.c
> +++ b/drivers/net/tokenring/skisa.c
> @@ -301,7 +301,7 @@ static void sk_isa_read_eeprom(struct net_device *dev)
>                dev->dev_addr[i] = sk_isa_sifreadw(dev, SIFINC) >> 8;
>  }
>
> -unsigned short sk_isa_setnselout_pins(struct net_device *dev)
> +static unsigned short sk_isa_setnselout_pins(struct net_device *dev)
>  {
>        return 0;
>  }
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 8e90891..4cb807e 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1189,7 +1189,7 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
>  * This needs to be a tasklet otherwise we will
>  * end up recursively calling this function.
>  */
> -void hso_unthrottle_tasklet(struct hso_serial *serial)
> +static void hso_unthrottle_tasklet(struct hso_serial *serial)
>  {
>        unsigned long flags;
>
> @@ -1208,7 +1208,7 @@ static    void hso_unthrottle(struct tty_struct *tty)
>        tasklet_hi_schedule(&serial->unthrottle_tasklet);
>  }
>
> -void hso_unthrottle_workfunc(struct work_struct *work)
> +static void hso_unthrottle_workfunc(struct work_struct *work)
>  {
>        struct hso_serial *serial =
>            container_of(work, struct hso_serial,
> diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
> index ee51b6a..ceb4a1b 100644
> --- a/drivers/net/wan/sbni.c
> +++ b/drivers/net/wan/sbni.c
> @@ -286,9 +286,7 @@ static int __init sbni_init(struct net_device *dev)
>        return  -ENODEV;
>  }
>
> -
> -int __init
> -sbni_pci_probe( struct net_device  *dev )
> +static int __init sbni_pci_probe(struct net_device *dev)
>  {
>        struct pci_dev  *pdev = NULL;
>
> diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
> index 2a6c7a6..348ab86 100644
> --- a/drivers/net/wan/x25_asy.c
> +++ b/drivers/net/wan/x25_asy.c
> @@ -624,7 +624,7 @@ static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
>   *                    STANDARD X.25 ENCAPSULATION                      *
>   ************************************************************************/
>
> -int x25_asy_esc(unsigned char *s, unsigned char *d, int len)
> +static int x25_asy_esc(unsigned char *s, unsigned char *d, int len)
>  {
>        unsigned char *ptr = d;
>        unsigned char c;
> diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
> index 5bf7e01..6a2751c 100644
> --- a/drivers/net/wan/z85230.c
> +++ b/drivers/net/wan/z85230.c
> @@ -601,7 +601,7 @@ static void z8530_dma_status(struct z8530_channel *chan)
>        write_zsctrl(chan, RES_H_IUS);
>  }
>
> -struct z8530_irqhandler z8530_dma_sync=
> +static struct z8530_irqhandler z8530_dma_sync =
>  {
>        z8530_dma_rx,
>        z8530_dma_tx,
> @@ -610,7 +610,7 @@ struct z8530_irqhandler z8530_dma_sync=
>
>  EXPORT_SYMBOL(z8530_dma_sync);
>
> -struct z8530_irqhandler z8530_txdma_sync=
> +static struct z8530_irqhandler z8530_txdma_sync =
>  {
>        z8530_rx,
>        z8530_dma_tx,
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index 370133e..20edc3a 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -3611,7 +3611,7 @@ badrx:
>        }
>  }
>
> -void mpi_receive_802_11 (struct airo_info *ai)
> +static void mpi_receive_802_11(struct airo_info *ai)
>  {
>        RxFid rxd;
>        struct sk_buff *skb = NULL;
> diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
> index ecb02bd..f5b22da 100644
> --- a/drivers/net/wireless/atmel.c
> +++ b/drivers/net/wireless/atmel.c
> @@ -3183,7 +3183,7 @@ static void associate(struct atmel_private *priv, u16 frame_len, u16 subtype)
>        }
>  }
>
> -void atmel_join_bss(struct atmel_private *priv, int bss_index)
> +static void atmel_join_bss(struct atmel_private *priv, int bss_index)
>  {
>        struct bss_info *bss =  &priv->BSSinfo[bss_index];
>
> diff --git a/drivers/net/wireless/b43/phy_a.c b/drivers/net/wireless/b43/phy_a.c
> index 0f1a84c..7fe9d17 100644
> --- a/drivers/net/wireless/b43/phy_a.c
> +++ b/drivers/net/wireless/b43/phy_a.c
> @@ -77,7 +77,7 @@ static s8 b43_aphy_estimate_power_out(struct b43_wldev *dev, s8 tssi)
>  }
>  #endif
>
> -void b43_radio_set_tx_iq(struct b43_wldev *dev)
> +static void b43_radio_set_tx_iq(struct b43_wldev *dev)
>  {
>        static const u8 data_high[5] = { 0x00, 0x40, 0x80, 0x90, 0xD0 };
>        static const u8 data_low[5] = { 0x00, 0x01, 0x05, 0x06, 0x0A };
> @@ -147,7 +147,7 @@ static void aphy_channel_switch(struct b43_wldev *dev, unsigned int channel)
>  //FIXME        b43_phy_xmitpower(dev);
>  }
>
> -void b43_radio_init2060(struct b43_wldev *dev)
> +static void b43_radio_init2060(struct b43_wldev *dev)
>  {
>        b43_radio_write16(dev, 0x0004, 0x00C0);
>        b43_radio_write16(dev, 0x0005, 0x0008);
> diff --git a/drivers/net/wireless/b43/phy_g.c b/drivers/net/wireless/b43/phy_g.c
> index 232181f..f07e1d3 100644
> --- a/drivers/net/wireless/b43/phy_g.c
> +++ b/drivers/net/wireless/b43/phy_g.c
> @@ -54,7 +54,7 @@ static const s8 b43_tssi2dbm_g_table[] = {
>        -20, -20, -20, -20,
>  };
>
> -const u8 b43_radio_channel_codes_bg[] = {
> +static const u8 b43_radio_channel_codes_bg[] = {
>        12, 17, 22, 27,
>        32, 37, 42, 47,
>        52, 57, 62, 67,
> @@ -215,7 +215,7 @@ void b43_gphy_set_baseband_attenuation(struct b43_wldev *dev,
>  }
>
>  /* Adjust the transmission power output (G-PHY) */
> -void b43_set_txpower_g(struct b43_wldev *dev,
> +static void b43_set_txpower_g(struct b43_wldev *dev,
>                       const struct b43_bbatt *bbatt,
>                       const struct b43_rfatt *rfatt, u8 tx_control)
>  {
> @@ -383,14 +383,14 @@ static void b43_set_original_gains(struct b43_wldev *dev)
>  }
>
>  /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
> -void b43_nrssi_hw_write(struct b43_wldev *dev, u16 offset, s16 val)
> +static void b43_nrssi_hw_write(struct b43_wldev *dev, u16 offset, s16 val)
>  {
>        b43_phy_write(dev, B43_PHY_NRSSILT_CTRL, offset);
>        b43_phy_write(dev, B43_PHY_NRSSILT_DATA, (u16) val);
>  }
>
>  /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
> -s16 b43_nrssi_hw_read(struct b43_wldev *dev, u16 offset)
> +static s16 b43_nrssi_hw_read(struct b43_wldev *dev, u16 offset)
>  {
>        u16 val;
>
> @@ -401,7 +401,7 @@ s16 b43_nrssi_hw_read(struct b43_wldev *dev, u16 offset)
>  }
>
>  /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
> -void b43_nrssi_hw_update(struct b43_wldev *dev, u16 val)
> +static void b43_nrssi_hw_update(struct b43_wldev *dev, u16 val)
>  {
>        u16 i;
>        s16 tmp;
> @@ -415,7 +415,7 @@ void b43_nrssi_hw_update(struct b43_wldev *dev, u16 val)
>  }
>
>  /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
> -void b43_nrssi_mem_update(struct b43_wldev *dev)
> +static void b43_nrssi_mem_update(struct b43_wldev *dev)
>  {
>        struct b43_phy_g *gphy = dev->phy.g;
>        s16 i, delta;
> @@ -589,7 +589,7 @@ static void b43_calc_nrssi_offset(struct b43_wldev *dev)
>        b43_phy_write(dev, 0x0811, backup[1]);
>  }
>
> -void b43_calc_nrssi_slope(struct b43_wldev *dev)
> +static void b43_calc_nrssi_slope(struct b43_wldev *dev)
>  {
>        struct b43_phy *phy = &dev->phy;
>        struct b43_phy_g *gphy = phy->g;
> @@ -1354,7 +1354,7 @@ struct init2050_saved_values {
>        u16 phy_syncctl;
>  };
>
> -u16 b43_radio_init2050(struct b43_wldev *dev)
> +static u16 b43_radio_init2050(struct b43_wldev *dev)
>  {
>        struct b43_phy *phy = &dev->phy;
>        struct init2050_saved_values sav;
> diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
> index bca7481..a3aa1de 100644
> --- a/drivers/net/wireless/ipw2100.c
> +++ b/drivers/net/wireless/ipw2100.c
> @@ -5271,21 +5271,21 @@ static int ipw2100_set_ibss_beacon_interval(struct ipw2100_priv *priv,
>        return 0;
>  }
>
> -void ipw2100_queues_initialize(struct ipw2100_priv *priv)
> +static void ipw2100_queues_initialize(struct ipw2100_priv *priv)
>  {
>        ipw2100_tx_initialize(priv);
>        ipw2100_rx_initialize(priv);
>        ipw2100_msg_initialize(priv);
>  }
>
> -void ipw2100_queues_free(struct ipw2100_priv *priv)
> +static void ipw2100_queues_free(struct ipw2100_priv *priv)
>  {
>        ipw2100_tx_free(priv);
>        ipw2100_rx_free(priv);
>        ipw2100_msg_free(priv);
>  }
>
> -int ipw2100_queues_allocate(struct ipw2100_priv *priv)
> +static int ipw2100_queues_allocate(struct ipw2100_priv *priv)
>  {
>        if (ipw2100_tx_allocate(priv) ||
>            ipw2100_rx_allocate(priv) || ipw2100_msg_allocate(priv))
> diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
> index af2e4f2..ddb21b7 100644
> --- a/drivers/net/wireless/prism54/islpci_hotplug.c
> +++ b/drivers/net/wireless/prism54/islpci_hotplug.c
> @@ -93,8 +93,7 @@ static struct pci_driver prism54_driver = {
>     Module initialization functions
>  ******************************************************************************/
>
> -int
> -prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
> +int static prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
>  {
>        struct net_device *ndev;
>        u8 latency_tmr;
> @@ -216,8 +215,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
>  static volatile int __in_cleanup_module = 0;
>
>  /* this one removes one(!!) instance only */
> -void
> -prism54_remove(struct pci_dev *pdev)
> +void static prism54_remove(struct pci_dev *pdev)
>  {
>        struct net_device *ndev = pci_get_drvdata(pdev);
>        islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
> @@ -259,8 +257,7 @@ prism54_remove(struct pci_dev *pdev)
>        pci_disable_device(pdev);
>  }
>
> -int
> -prism54_suspend(struct pci_dev *pdev, pm_message_t state)
> +int static prism54_suspend(struct pci_dev *pdev, pm_message_t state)
>  {
>        struct net_device *ndev = pci_get_drvdata(pdev);
>        islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
> @@ -282,8 +279,7 @@ prism54_suspend(struct pci_dev *pdev, pm_message_t state)
>        return 0;
>  }
>
> -int
> -prism54_resume(struct pci_dev *pdev)
> +int static prism54_resume(struct pci_dev *pdev)
>  {
>        struct net_device *ndev = pci_get_drvdata(pdev);
>        islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
> diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
> index 1404a57..1512b17 100644
> --- a/drivers/net/wireless/ray_cs.c
> +++ b/drivers/net/wireless/ray_cs.c
> @@ -829,7 +829,7 @@ static int ray_resume(struct pcmcia_device *link)
>  }
>
>  /*===========================================================================*/
> -int ray_dev_init(struct net_device *dev)
> +static int ray_dev_init(struct net_device *dev)
>  {
>  #ifdef RAY_IMMEDIATE_INIT
>     int i;
>
>

Adding Netdev...

Please make sure you CC netdev for networking patches.

-- 
Cheers,
Jeff
