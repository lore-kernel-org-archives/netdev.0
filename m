From: Qinghuang Feng <qhfeng.kernel@gmail.com>
Subject: [PATCH 0/3] report: function comments cleanup and the remained
 problem
Date: Sat, 22 Nov 2008 15:40:32 +0800
Message-ID: <4927b786.06876e0a.7ff6.7be4@mx.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:2438 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbYKVHk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:40:57 -0500
Received: by ti-out-0910.google.com with SMTP id b6so794718tic.23
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 23:40:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

The following is the result after scaning with my script.

meaning:
count_less: functions with insufficient argument comments.
count_more: functions with redundant argument comments

The patches have cleaned up the "count_more", but except velocity_rx_copy() 
and zd_op_tx(). As I am not sure how to change them precisely. 
They are pointed out with "-->" in the first list.

------
Over! All files in drivers/net/ have been checked.
start: Sat Nov 22 13:53:49 2008
end:   Sat Nov 22 13:53:51 2008
count: 
$count_less: 89
$count_more: 15
-----------
The summary for count-more:

-->1: static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size, struct velocity_info *vptr)
in: drivers/net/via-velocity.c

2: static irqreturn_t ax_interrupt(int irq, void *dev_id)
in: drivers/net/pcmcia/axnet_cs.c

3: static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
in: drivers/net/sis900.c

4: static inline struct sk_buff *get_packet(struct pci_dev *pdev, struct freelQ *fl, unsigned int len)
in: drivers/net/chelsio/sge.c

5: static int spider_net_prepare_tx_descr(struct spider_net_card *card, struct sk_buff *skb)
in: drivers/net/spider_net.c

6: static inline void spider_net_kick_tx_dma(struct spider_net_card *card)
in: drivers/net/spider_net.c

7: static irqreturn_t spider_net_interrupt(int irq, void *ptr)
in: drivers/net/spider_net.c

8: static struct spider_net_card * spider_net_setup_pci_dev(struct pci_dev *pdev)
in: drivers/net/spider_net.c

9: static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter, int cleaned_count)
in: drivers/net/e1000e/netdev.c

10: static irqreturn_t ixgbe_intr(int irq, void *data)
in: drivers/net/ixgbe/ixgbe_main.c

11: static void igb_free_tx_resources(struct igb_ring *tx_ring)
in: drivers/net/igb/igb_main.c

12: static void igb_clean_tx_ring(struct igb_ring *tx_ring)
in: drivers/net/igb/igb_main.c

13: static void igb_free_rx_resources(struct igb_ring *rx_ring)
in: drivers/net/igb/igb_main.c

14: static void igb_clean_rx_ring(struct igb_ring *rx_ring)
in: drivers/net/igb/igb_main.c

-->15: static int zd_op_tx(struct ieee80211_hw *hw, struct sk_buff *skb) 
in: drivers/net/wireless/zd1211rw/zd_mac.c

-----------
The summary for count-less:

1: int t3_sge_cqcntxt_op(struct adapter *adapter, unsigned int id, unsigned int op, unsigned int credits)
in: drivers/net/cxgb3/t3_hw.c

2: static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl, struct sge_rspq *q, unsigned int len, unsigned int drop_thres)
in: drivers/net/cxgb3/sge.c

3: static void rx_eth(struct adapter *adap, struct sge_rspq *rq, struct sk_buff *skb, int pad, int lro)
in: drivers/net/cxgb3/sge.c

4: static void init_lro_mgr(struct sge_qset *qs, struct net_lro_mgr *lro_mgr)
in: drivers/net/cxgb3/sge.c

5: static void gelic_ether_setup_netdev_ops(struct net_device *netdev, struct napi_struct *napi)
in: drivers/net/ps3_gelic_net.c

6: static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
in: drivers/net/via-velocity.c

7: static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
in: drivers/net/via-velocity.c

8: static u16 wol_calc_crc(int size, u8 * pattern, u8 *mask_pattern)
in: drivers/net/via-velocity.c

9: static void sis900_set_capability(struct net_device *net_dev, struct mii_phy *phy)
in: drivers/net/sis900.c

10: static void sis900_set_mode (long ioaddr, int speed, int duplex)
in: drivers/net/sis900.c

11: static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex)
in: drivers/net/sis900.c

12: static int ixgb_clean(struct napi_struct *napi, int budget)
in: drivers/net/ixgb/ixgb_main.c

13: static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
in: drivers/net/ixgb/ixgb_main.c

14: static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter, int cleaned_count)
in: drivers/net/ixgb/ixgb_main.c

15: static u8 spider_net_get_multicast_hash(struct net_device *netdev, __u8 *addr)
in: drivers/net/spider_net.c

16: static void spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg, u32 error_reg1, u32 error_reg2)
in: drivers/net/spider_net.c

17: static int e1000_clean(struct napi_struct *napi, int budget)
in: drivers/net/e1000/e1000_main.c

18: static bool e1000_clean_tx_irq(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring)
in: drivers/net/e1000/e1000_main.c

19: static bool e1000_clean_rx_irq(struct e1000_adapter *adapter, struct e1000_rx_ring *rx_ring, int *work_done, int work_to_do)
in: drivers/net/e1000/e1000_main.c

20: static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter, struct e1000_rx_ring *rx_ring, int cleaned_count)
in: drivers/net/e1000/e1000_main.c

21: static int start_nic(struct s2io_nic *nic)
in: drivers/net/s2io.c

22: static void free_tx_buffers(struct s2io_nic *nic)
in: drivers/net/s2io.c

23: static int s2io_poll_msix(struct napi_struct *napi, int budget)
in: drivers/net/s2io.c

24: static void s2io_netpoll(struct net_device *dev)
in: drivers/net/s2io.c

25: static void tx_intr_handler(struct fifo_info *fifo_data)
in: drivers/net/s2io.c

26: static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value, struct net_device *dev)
in: drivers/net/s2io.c

27: static u64 s2io_mdio_read(u32 mmd_type, u64 addr, struct net_device *dev)
in: drivers/net/s2io.c

28: static void s2io_chk_xpak_counter(u64 *counter, u64 * regs_stat, u32 index, u16 flag, u16 type)
in: drivers/net/s2io.c

29: static void s2io_updt_xpak_counter(struct net_device *dev)
in: drivers/net/s2io.c

30: static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit, int bit_state)
in: drivers/net/s2io.c

31: static void s2io_reset(struct s2io_nic * sp)
in: drivers/net/s2io.c

32: static int s2io_set_swapper(struct s2io_nic * sp)
in: drivers/net/s2io.c

33: static int s2io_open(struct net_device *dev)
in: drivers/net/s2io.c

34: static int s2io_close(struct net_device *dev)
in: drivers/net/s2io.c

35: static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
in: drivers/net/s2io.c

36: static struct net_device_stats *s2io_get_stats(struct net_device *dev)
in: drivers/net/s2io.c

37: static void s2io_set_multicast(struct net_device *dev)
in: drivers/net/s2io.c

38: static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
in: drivers/net/s2io.c

39: static int s2io_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
in: drivers/net/s2io.c

40: static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
in: drivers/net/s2io.c

41: static void s2io_ethtool_gdrvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
in: drivers/net/s2io.c

42: static void s2io_ethtool_gregs(struct net_device *dev, struct ethtool_regs *regs, void *space)
in: drivers/net/s2io.c

43: static void s2io_phy_id(unsigned long data)
in: drivers/net/s2io.c

44: static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
in: drivers/net/s2io.c

45: static void s2io_ethtool_getpause_data(struct net_device *dev, struct ethtool_pauseparam *ep)
in: drivers/net/s2io.c

46: static int s2io_ethtool_setpause_data(struct net_device *dev, struct ethtool_pauseparam *ep)
in: drivers/net/s2io.c

47: static int write_eeprom(struct s2io_nic * sp, int off, u64 data, int cnt)
in: drivers/net/s2io.c

48: static int s2io_ethtool_geeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 * data_buf)
in: drivers/net/s2io.c

49: static int s2io_ethtool_seeprom(struct net_device *dev, struct ethtool_eeprom *eeprom, u8 * data_buf)
in: drivers/net/s2io.c

50: static int s2io_register_test(struct s2io_nic * sp, uint64_t * data)
in: drivers/net/s2io.c

51: static int s2io_eeprom_test(struct s2io_nic * sp, uint64_t * data)
in: drivers/net/s2io.c

52: static int s2io_bist_test(struct s2io_nic * sp, uint64_t * data)
in: drivers/net/s2io.c

53: static void s2io_ethtool_test(struct net_device *dev, struct ethtool_test *ethtest, uint64_t * data)
in: drivers/net/s2io.c

54: static int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
in: drivers/net/s2io.c

55: static int s2io_change_mtu(struct net_device *dev, int new_mtu)
in: drivers/net/s2io.c

56: static void s2io_restart_nic(struct work_struct *work)
in: drivers/net/s2io.c

57: static void s2io_tx_watchdog(struct net_device *dev)
in: drivers/net/s2io.c

58: static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
in: drivers/net/s2io.c

59: static void s2io_link(struct s2io_nic * sp, int link)
in: drivers/net/s2io.c

60: static void s2io_init_pci(struct s2io_nic * sp)
in: drivers/net/s2io.c

61: static int rts_ds_steer(struct s2io_nic *nic, u8 ds_codepoint, u8 ring)
in: drivers/net/s2io.c

62: static int __devinit s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
in: drivers/net/s2io.c

63: static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg)
in: drivers/net/e1000e/phy.c

64: static void e1000_receive_skb(struct e1000_adapter *adapter, struct net_device *netdev, struct sk_buff *skb, u8 status, __le16 vlan)
in: drivers/net/e1000e/netdev.c

65: static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter, int cleaned_count)
in: drivers/net/e1000e/netdev.c

66: static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter, int cleaned_count)
in: drivers/net/e1000e/netdev.c

67: static bool e1000_clean_rx_irq(struct e1000_adapter *adapter, int *work_done, int work_to_do)
in: drivers/net/e1000e/netdev.c

68: static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter, int *work_done, int work_to_do)
in: drivers/net/e1000e/netdev.c

69: static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter, int *work_done, int work_to_do)
in: drivers/net/e1000e/netdev.c

70: static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter, struct ixgbe_ring *rx_ring, int cleaned_count)
in: drivers/net/ixgbe/ixgbe_main.c

71: static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr)
in: drivers/net/ixgbe/ixgbe_phy.c

72: s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr, u32 device_type, u16 *phy_data)
in: drivers/net/ixgbe/ixgbe_phy.c

73: s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw, ixgbe_link_speed speed, bool autoneg, bool autoneg_wait_to_complete)
in: drivers/net/ixgbe/ixgbe_phy.c

74: static u16 ixgbe_shift_in_eeprom_bits(struct ixgbe_hw *hw, u16 count)
in: drivers/net/ixgbe/ixgbe_common.c

75: static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
in: drivers/net/ixgbe/ixgbe_common.c

76: static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
in: drivers/net/igb/igb_main.c

77: static int ipw_sw_reset(struct ipw_priv *priv, int option)
in: drivers/net/wireless/ipw2200.c

78: static int if_usb_issue_boot_command(struct if_usb_card *cardp, int ivalue)
in: drivers/net/wireless/libertas/if_usb.c

79: int ath5k_hw_set_txdp(struct ath5k_hw *ah, unsigned int queue, u32 phys_addr)
in: drivers/net/wireless/ath5k/dma.c

80: static void wl3501_set_to_wla(struct wl3501_card *this, u16 dest, void *src, int size)
in: drivers/net/wireless/wl3501_cs.c

81: static void wl3501_get_from_wla(struct wl3501_card *this, u16 src, void *dest, int size)
in: drivers/net/wireless/wl3501_cs.c

82: static void iwl_tx_queue_free(struct iwl_priv *priv, int txq_id)
in: drivers/net/wireless/iwlwifi/iwl-tx.c

83: void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
in: drivers/net/wireless/iwlwifi/iwl-tx.c

84: int iwl_scan_cancel_timeout(struct iwl_priv *priv, unsigned long ms)
in: drivers/net/wireless/iwlwifi/iwl-scan.c

85: void iwl3945_tx_queue_free(struct iwl3945_priv *priv, struct iwl3945_tx_queue *txq)
in: drivers/net/wireless/iwlwifi/iwl3945-base.c

86: static int iwl3945_set_rxon_channel(struct iwl3945_priv *priv, enum ieee80211_band band, u16 channel)
in: drivers/net/wireless/iwlwifi/iwl3945-base.c

87: static int iwl3945_scan_cancel_timeout(struct iwl3945_priv *priv, unsigned long ms)
in: drivers/net/wireless/iwlwifi/iwl3945-base.c

88: static void iwl3945_tx_cmd_complete(struct iwl3945_priv *priv, struct iwl3945_rx_mem_buffer *rxb)
in: drivers/net/wireless/iwlwifi/iwl3945-base.c

89: static void iwl4965_tx_queue_set_status(struct iwl_priv *priv, struct iwl_tx_queue *txq, int tx_fifo_id, int scd_retry)
in: drivers/net/wireless/iwlwifi/iwl-4965.c

