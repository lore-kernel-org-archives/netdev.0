From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 6/8] treewide: Remove unnecessary casts from skb_puts
Date: Mon,  4 May 2015 13:05:50 -0700
Message-ID: <0a877a2bec082e723468ea47529614fd4ab43c96.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0115.hostedemail.com ([216.40.44.115]:47592 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750992AbbEDUGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:22 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay07.hostedemail.com (Postfix) with ESMTP id 2B184C211B
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:21 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:16 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that skb_puts returns a void *, remove the unnecessary casts.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/atm/atmtcp.c                               |   4 +-
 drivers/atm/solos-pci.c                            |  12 +-
 drivers/bluetooth/btmrvl_main.c                    |   2 +-
 drivers/bluetooth/btusb.c                          |   4 +-
 drivers/bluetooth/hci_ll.c                         |   2 +-
 drivers/infiniband/hw/cxgb3/cxio_hal.c             |   4 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |  24 ++--
 drivers/infiniband/hw/cxgb3/iwch_qp.c              |   4 +-
 drivers/infiniband/hw/cxgb4/cm.c                   |  26 ++---
 drivers/isdn/act2000/capi.c                        |   4 +-
 drivers/isdn/hisax/isar.c                          |   6 +-
 drivers/isdn/i4l/isdn_audio.c                      |   4 +-
 drivers/media/dvb-core/dvb_net.c                   |   2 +-
 drivers/media/radio/wl128x/fmdrv_common.c          |   2 +-
 drivers/net/bonding/bond_3ad.c                     |   4 +-
 drivers/net/can/dev.c                              |   4 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |   2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   2 +-
 drivers/net/ethernet/davicom/dm9000.c              |   2 +-
 drivers/net/ethernet/dnet.c                        |   2 +-
 drivers/net/ethernet/hp/hp100.c                    |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |   4 +-
 drivers/net/ethernet/micrel/ks8842.c               |   4 +-
 drivers/net/ethernet/sfc/selftest.c                |   3 +-
 drivers/net/ethernet/sun/sunvnet.c                 |   2 +-
 drivers/net/ppp/pppoe.c                            |   2 +-
 drivers/net/usb/net1080.c                          |   2 +-
 drivers/net/vxlan.c                                |   2 +-
 drivers/net/wan/hdlc_ppp.c                         |   2 +-
 drivers/net/wireless/airo.c                        |   4 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   2 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   6 +-
 drivers/net/wireless/ath/ath9k/channel.c           |   2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |   9 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |   2 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   2 +-
 drivers/net/wireless/hostap/hostap_ap.c            |   4 +-
 drivers/net/wireless/hostap/hostap_main.c          |   3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   2 +-
 drivers/net/wireless/ipw2x00/libipw_tx.c           |   6 +-
 drivers/net/wireless/mac80211_hwsim.c              |   8 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   2 +-
 drivers/net/wireless/mwifiex/tdls.c                |  30 ++---
 drivers/net/wireless/p54/fwio.c                    |  43 ++++---
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   2 +-
 drivers/net/wireless/rtlwifi/base.c                |   4 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |   5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c        |   8 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   2 +-
 drivers/nfc/nfcwilink.c                            |   3 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                  |   2 +-
 drivers/scsi/fcoe/fcoe.c                           |   2 +-
 drivers/scsi/fcoe/fcoe_ctlr.c                      |   2 +-
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c   |   2 +-
 drivers/staging/ft1000/ft1000-usb/ft1000_hw.c      |   2 +-
 drivers/staging/ozwpan/ozpd.c                      |   6 +-
 drivers/staging/ozwpan/ozproto.c                   |   2 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c          |   2 +-
 drivers/staging/rtl8192e/rtl819x_BAProc.c          |  10 +-
 drivers/staging/rtl8192e/rtllib_rx.c               |   4 +-
 drivers/staging/rtl8192e/rtllib_softmac.c          |  34 ++----
 drivers/staging/rtl8192e/rtllib_tx.c               |   3 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |   2 +-
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |  21 ++--
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |   2 +-
 .../staging/rtl8192u/ieee80211/rtl819x_BAProc.c    |   8 +-
 drivers/staging/rtl8712/rtl8712_recv.c             |   2 +-
 drivers/usb/gadget/function/f_ncm.c                |  19 ++--
 lib/nlattr.c                                       |   2 +-
 net/appletalk/ddp.c                                |   2 +-
 net/atm/clip.c                                     |   2 +-
 net/atm/signaling.c                                |   2 +-
 net/batman-adv/icmp_socket.c                       |   2 +-
 net/bluetooth/hci_request.c                        |   2 +-
 net/bluetooth/hci_sock.c                           |   6 +-
 net/bluetooth/l2cap_core.c                         |  16 +--
 net/bluetooth/mgmt_util.c                          |  10 +-
 net/bridge/netfilter/nft_reject_bridge.c           |   4 +-
 net/core/pktgen.c                                  |  32 +++---
 net/decnet/dn_dev.c                                |   2 +-
 net/decnet/dn_nsp_out.c                            |   6 +-
 net/ipv4/arp.c                                     |   2 +-
 net/ipv4/igmp.c                                    |   6 +-
 net/ipv4/ipconfig.c                                |   2 +-
 net/ipv4/ipmr.c                                    |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |  10 +-
 net/ipv4/netfilter/nf_reject_ipv4.c                |   4 +-
 net/ipv6/mcast.c                                   |   6 +-
 net/ipv6/ndisc.c                                   |   8 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |  10 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                |   2 +-
 net/irda/irlap_frame.c                             |  17 ++-
 net/key/af_key.c                                   | 124 +++++++++------------
 net/mac80211/agg-rx.c                              |   2 +-
 net/mac80211/agg-tx.c                              |   4 +-
 net/mac80211/cfg.c                                 |   4 +-
 net/mac80211/debugfs_netdev.c                      |   2 +-
 net/mac80211/ht.c                                  |   4 +-
 net/mac80211/mesh.c                                |   4 +-
 net/mac80211/mesh_hwmp.c                           |   4 +-
 net/mac80211/mesh_plink.c                          |   2 +-
 net/mac80211/mesh_ps.c                             |   2 +-
 net/mac80211/mlme.c                                |   4 +-
 net/mac80211/rx.c                                  |   2 +-
 net/mac80211/spectmgmt.c                           |   2 +-
 net/mac80211/sta_info.c                            |   2 +-
 net/mac80211/tdls.c                                |  14 +--
 net/mac80211/tx.c                                  |   9 +-
 net/mac80211/util.c                                |   4 +-
 net/mac80211/wpa.c                                 |   6 +-
 net/netfilter/nfnetlink_log.c                      |   2 +-
 net/netfilter/nfnetlink_queue_core.c               |   2 +-
 net/netlink/af_netlink.c                           |   2 +-
 net/nfc/digital_technology.c                       |   6 +-
 net/nfc/nci/core.c                                 |   2 +-
 net/phonet/datagram.c                              |   2 +-
 net/sctp/sm_make_chunk.c                           |   2 +-
 net/sctp/ulpevent.c                                |  21 ++--
 128 files changed, 389 insertions(+), 445 deletions(-)

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index 480fa6f..43c5b81 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -60,7 +60,7 @@ static int atmtcp_send_control(struct atm_vcc *vcc,int type,
 		return -EUNATCH;
 	}
 	atm_force_charge(out_vcc,skb->truesize);
-	new_msg = (struct atmtcp_control *) skb_put(skb,sizeof(*new_msg));
+	new_msg = skb_put(skb, sizeof(*new_msg));
 	*new_msg = *msg;
 	new_msg->hdr.length = ATMTCP_HDR_MAGIC;
 	new_msg->type = type;
@@ -217,7 +217,7 @@ static int atmtcp_v_send(struct atm_vcc *vcc,struct sk_buff *skb)
 		atomic_inc(&vcc->stats->tx_err);
 		return -ENOBUFS;
 	}
-	hdr = (void *) skb_put(new_skb,sizeof(struct atmtcp_hdr));
+	hdr = skb_put(new_skb, sizeof(struct atmtcp_hdr));
 	hdr->vpi = htons(vcc->vpi);
 	hdr->vci = htons(vcc->vci);
 	hdr->length = htonl(skb->len);
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 74e18b0..d762ee9 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -205,7 +205,7 @@ static ssize_t solos_param_show(struct device *dev, struct device_attribute *att
 		return -ENOMEM;
 	}
 
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	buflen = snprintf((void *)&header[1], buflen - 1,
 			  "L%05d\n%s\n", current->pid, attr->attr.name);
@@ -261,7 +261,7 @@ static ssize_t solos_param_store(struct device *dev, struct device_attribute *at
 		return -ENOMEM;
 	}
 
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	buflen = snprintf((void *)&header[1], buflen - 1,
 			  "L%05d\n%s\n%s\n", current->pid, attr->attr.name, buf);
@@ -480,7 +480,7 @@ static int send_command(struct solos_card *card, int dev, const char *buf, size_
 		return 0;
 	}
 
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	header->size = cpu_to_le16(size);
 	header->vpi = cpu_to_le16(0);
@@ -931,7 +931,7 @@ static int popen(struct atm_vcc *vcc)
 			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
 		return -ENOMEM;
 	}
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
@@ -968,7 +968,7 @@ static void pclose(struct atm_vcc *vcc)
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in pclose()\n");
 		return;
 	}
-	header = (void *)skb_put(skb, sizeof(*header));
+	header = skb_put(skb, sizeof(*header));
 
 	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
@@ -1384,7 +1384,7 @@ static int atm_init(struct solos_card *card, struct device *parent)
 			continue;
 		}
 
-		header = (void *)skb_put(skb, sizeof(*header));
+		header = skb_put(skb, sizeof(*header));
 
 		header->size = cpu_to_le16(0);
 		header->vpi = cpu_to_le16(0);
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index de05deb..03707fb 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -189,7 +189,7 @@ static int btmrvl_send_sync_cmd(struct btmrvl_private *priv, u16 opcode,
 		return -ENOMEM;
 	}
 
-	hdr = (struct hci_command_hdr *)skb_put(skb, HCI_COMMAND_HDR_SIZE);
+	hdr = skb_put(skb, HCI_COMMAND_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(opcode);
 	hdr->plen = len;
 
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index fbc9fb9..32f5f55 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -1718,11 +1718,11 @@ static int inject_cmd_complete(struct hci_dev *hdev, __u16 opcode)
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (struct hci_event_hdr *)skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->evt = HCI_EV_CMD_COMPLETE;
 	hdr->plen = sizeof(*evt) + 1;
 
-	evt = (struct hci_ev_cmd_complete *)skb_put(skb, sizeof(*evt));
+	evt = skb_put(skb, sizeof(*evt));
 	evt->ncmd = 0x01;
 	evt->opcode = cpu_to_le16(opcode);
 
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 68bdf3f..0860304 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -108,7 +108,7 @@ static int send_hcill_cmd(u8 cmd, struct hci_uart *hu)
 	}
 
 	/* prepare packet */
-	hcill_packet = (struct hcill_cmd *) skb_put(skb, 1);
+	hcill_packet = skb_put(skb, 1);
 	hcill_packet->cmd = cmd;
 
 	/* send packet */
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index de1c61b4..c3c9883 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -143,7 +143,7 @@ static int cxio_hal_clear_qp_ctx(struct cxio_rdev *rdev_p, u32 qpid)
 		PDBG("%s alloc_skb failed\n", __func__);
 		return -ENOMEM;
 	}
-	wqe = (struct t3_modify_qp_wr *) skb_put(skb, sizeof(*wqe));
+	wqe = skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof(*wqe));
 	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD,
 		       T3_COMPLETION_FLAG | T3_NOTIFY_FLAG, 0, qpid, 7,
@@ -562,7 +562,7 @@ static int cxio_hal_init_ctrl_qp(struct cxio_rdev *rdev_p)
 	ctx1 |= ((u64) (V_EC_BASE_HI((u32) base_addr & 0xf) | V_EC_RESPQ(0) |
 			V_EC_TYPE(0) | V_EC_GEN(1) |
 			V_EC_UP_TOKEN(T3_CTL_QP_TID) | F_EC_VALID)) << 32;
-	wqe = (struct t3_modify_qp_wr *) skb_put(skb, sizeof(*wqe));
+	wqe = skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof(*wqe));
 	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD, 0, 0,
 		       T3_CTL_QP_TID, 7, T3_SOPEOP);
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index cb78b1e..b115582 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -175,7 +175,7 @@ static void release_tid(struct t3cdev *tdev, u32 hwtid, struct sk_buff *skb)
 	skb = get_skb(skb, sizeof *req, GFP_KERNEL);
 	if (!skb)
 		return;
-	req = (struct cpl_tid_release *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_TID_RELEASE, hwtid));
 	skb->priority = CPL_PRIORITY_SETUP;
@@ -190,7 +190,7 @@ int iwch_quiesce_tid(struct iwch_ep *ep)
 
 	if (!skb)
 		return -ENOMEM;
-	req = (struct cpl_set_tcb_field *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, ep->hwtid));
@@ -211,7 +211,7 @@ int iwch_resume_tid(struct iwch_ep *ep)
 
 	if (!skb)
 		return -ENOMEM;
-	req = (struct cpl_set_tcb_field *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, ep->hwtid));
@@ -397,7 +397,7 @@ static int send_halfclose(struct iwch_ep *ep, gfp_t gfp)
 	}
 	skb->priority = CPL_PRIORITY_DATA;
 	set_arp_failure_handler(skb, arp_failure_discard);
-	req = (struct cpl_close_con_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_CLOSE_CON));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_CON_REQ, ep->hwtid));
@@ -417,7 +417,7 @@ static int send_abort(struct iwch_ep *ep, struct sk_buff *skb, gfp_t gfp)
 	}
 	skb->priority = CPL_PRIORITY_DATA;
 	set_arp_failure_handler(skb, abort_arp_failure);
-	req = (struct cpl_abort_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_REQ));
 	req->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
@@ -457,7 +457,7 @@ static int send_connect(struct iwch_ep *ep)
 	skb->priority = CPL_PRIORITY_SETUP;
 	set_arp_failure_handler(skb, act_open_req_arp_failure);
 
-	req = (struct cpl_act_open_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_ACT_OPEN_REQ, ep->atid));
 	req->local_port = ep->com.local_addr.sin_port;
@@ -548,7 +548,7 @@ static int send_mpa_reject(struct iwch_ep *ep, const void *pdata, u8 plen)
 		return -ENOMEM;
 	}
 	skb_reserve(skb, sizeof(*req));
-	mpa = (struct mpa_message *) skb_put(skb, mpalen);
+	mpa = skb_put(skb, mpalen);
 	memset(mpa, 0, sizeof(*mpa));
 	memcpy(mpa->key, MPA_KEY_REP, sizeof(mpa->key));
 	mpa->flags = MPA_REJECT;
@@ -598,7 +598,7 @@ static int send_mpa_reply(struct iwch_ep *ep, const void *pdata, u8 plen)
 	}
 	skb->priority = CPL_PRIORITY_DATA;
 	skb_reserve(skb, sizeof(*req));
-	mpa = (struct mpa_message *) skb_put(skb, mpalen);
+	mpa = skb_put(skb, mpalen);
 	memset(mpa, 0, sizeof(*mpa));
 	memcpy(mpa->key, MPA_KEY_REP, sizeof(mpa->key));
 	mpa->flags = (ep->mpa_attr.crc_enabled ? MPA_CRC : 0) |
@@ -802,7 +802,7 @@ static int update_rx_credits(struct iwch_ep *ep, u32 credits)
 		return 0;
 	}
 
-	req = (struct cpl_rx_data_ack *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RX_DATA_ACK, ep->hwtid));
 	req->credit_dack = htonl(V_RX_CREDITS(credits) | V_RX_FORCE_ACK(1));
@@ -1209,7 +1209,7 @@ static int listen_start(struct iwch_listen_ep *ep)
 		return -ENOMEM;
 	}
 
-	req = (struct cpl_pass_open_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_PASS_OPEN_REQ, ep->stid));
 	req->local_port = ep->com.local_addr.sin_port;
@@ -1250,7 +1250,7 @@ static int listen_stop(struct iwch_listen_ep *ep)
 		printk(KERN_ERR MOD "%s - failed to alloc skb\n", __func__);
 		return -ENOMEM;
 	}
-	req = (struct cpl_close_listserv_req *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	req->cpu_idx = 0;
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, ep->stid));
@@ -1626,7 +1626,7 @@ static int peer_abort(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		goto out;
 	}
 	rpl_skb->priority = CPL_PRIORITY_DATA;
-	rpl = (struct cpl_abort_rpl *) skb_put(rpl_skb, sizeof(*rpl));
+	rpl = skb_put(rpl_skb, sizeof(*rpl));
 	rpl->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_RPL));
 	rpl->wr.wr_lo = htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(rpl) = htonl(MK_OPCODE_TID(CPL_ABORT_RPL, ep->hwtid));
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index b57c0be..59375ff 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -751,7 +751,7 @@ int iwch_post_zb_read(struct iwch_ep *ep)
 		printk(KERN_ERR "%s cannot send zb_read!!\n", __func__);
 		return -ENOMEM;
 	}
-	wqe = (union t3_wr *)skb_put(skb, sizeof(struct t3_rdma_read_wr));
+	wqe = skb_put(skb, sizeof(struct t3_rdma_read_wr));
 	memset(wqe, 0, sizeof(struct t3_rdma_read_wr));
 	wqe->read.rdmaop = T3_READ_REQ;
 	wqe->read.reserved[0] = 0;
@@ -783,7 +783,7 @@ int iwch_post_terminate(struct iwch_qp *qhp, struct respQ_msg_t *rsp_msg)
 		printk(KERN_ERR "%s cannot send TERMINATE!\n", __func__);
 		return -ENOMEM;
 	}
-	wqe = (union t3_wr *)skb_put(skb, 40);
+	wqe = skb_put(skb, 40);
 	memset(wqe, 0, 40);
 	wqe->send.rdmaop = T3_TERMINATE;
 
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 57176dd..a6c17e4 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -225,7 +225,7 @@ static void release_tid(struct c4iw_rdev *rdev, u32 hwtid, struct sk_buff *skb)
 	skb = get_skb(skb, sizeof *req, GFP_KERNEL);
 	if (!skb)
 		return;
-	req = (struct cpl_tid_release *) skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, hwtid);
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_TID_RELEASE, hwtid));
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, 0);
@@ -521,7 +521,7 @@ static int send_halfclose(struct c4iw_ep *ep, gfp_t gfp)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 	t4_set_arp_err_handler(skb, NULL, arp_failure_discard);
-	req = (struct cpl_close_con_req *) skb_put(skb, wrlen);
+	req = skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	INIT_TP_WR(req, ep->hwtid);
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_CLOSE_CON_REQ,
@@ -543,7 +543,7 @@ static int send_abort(struct c4iw_ep *ep, struct sk_buff *skb, gfp_t gfp)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 	t4_set_arp_err_handler(skb, &ep->com.dev->rdev, abort_arp_failure);
-	req = (struct cpl_abort_req *) skb_put(skb, wrlen);
+	req = skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	INIT_TP_WR(req, ep->hwtid);
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_REQ, ep->hwtid));
@@ -681,7 +681,7 @@ static int send_connect(struct c4iw_ep *ep)
 
 	if (is_t4(ep->com.dev->rdev.lldi.adapter_type)) {
 		if (ep->com.remote_addr.ss_family == AF_INET) {
-			req = (struct cpl_act_open_req *) skb_put(skb, wrlen);
+			req = skb_put(skb, wrlen);
 			INIT_TP_WR(req, 0);
 			OPCODE_TID(req) = cpu_to_be32(
 					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
@@ -696,7 +696,7 @@ static int send_connect(struct c4iw_ep *ep)
 						ep->l2t));
 			req->opt2 = cpu_to_be32(opt2);
 		} else {
-			req6 = (struct cpl_act_open_req6 *)skb_put(skb, wrlen);
+			req6 = skb_put(skb, wrlen);
 
 			INIT_TP_WR(req6, 0);
 			OPCODE_TID(req6) = cpu_to_be32(
@@ -725,8 +725,7 @@ static int send_connect(struct c4iw_ep *ep)
 			isn += 4;
 
 		if (ep->com.remote_addr.ss_family == AF_INET) {
-			t5_req = (struct cpl_t5_act_open_req *)
-				 skb_put(skb, wrlen);
+			t5_req = skb_put(skb, wrlen);
 			INIT_TP_WR(t5_req, 0);
 			OPCODE_TID(t5_req) = cpu_to_be32(
 					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
@@ -745,8 +744,7 @@ static int send_connect(struct c4iw_ep *ep)
 			     be32_to_cpu(t5_req->rsvd));
 			t5_req->opt2 = cpu_to_be32(opt2);
 		} else {
-			t5_req6 = (struct cpl_t5_act_open_req6 *)
-				  skb_put(skb, wrlen);
+			t5_req6 = skb_put(skb, wrlen);
 			INIT_TP_WR(t5_req6, 0);
 			OPCODE_TID(t5_req6) = cpu_to_be32(
 					      MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
@@ -800,7 +798,7 @@ static void send_mpa_req(struct c4iw_ep *ep, struct sk_buff *skb,
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	req = (struct fw_ofld_tx_data_wr *)skb_put(skb, wrlen);
+	req = skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
 		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
@@ -894,7 +892,7 @@ static int send_mpa_reject(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	req = (struct fw_ofld_tx_data_wr *)skb_put(skb, wrlen);
+	req = skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
 		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
@@ -974,7 +972,7 @@ static int send_mpa_reply(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
 
-	req = (struct fw_ofld_tx_data_wr *) skb_put(skb, wrlen);
+	req = skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	req->op_to_immdlen = cpu_to_be32(
 		FW_WR_OP_V(FW_OFLD_TX_DATA_WR) |
@@ -1252,7 +1250,7 @@ static int update_rx_credits(struct c4iw_ep *ep, u32 credits)
 	if (ep->rcv_win > RCV_BUFSIZ_M * 1024)
 		credits += ep->rcv_win - RCV_BUFSIZ_M * 1024;
 
-	req = (struct cpl_rx_data_ack *) skb_put(skb, wrlen);
+	req = skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	INIT_TP_WR(req, ep->hwtid);
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK,
@@ -2610,7 +2608,7 @@ static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto out;
 	}
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
-	rpl = (struct cpl_abort_rpl *) skb_put(rpl_skb, sizeof(*rpl));
+	rpl = skb_put(rpl_skb, sizeof(*rpl));
 	INIT_TP_WR(rpl, ep->hwtid);
 	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_RPL, ep->hwtid));
 	rpl->cmd = CPL_ABORT_NO_RST;
diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
index 3f66ca2..3e70135 100644
--- a/drivers/isdn/act2000/capi.c
+++ b/drivers/isdn/act2000/capi.c
@@ -107,7 +107,7 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
 #define ACTCAPI_MKHDR(l, c, s) {				\
 		skb = alloc_skb(l + 8, GFP_ATOMIC);		\
 		if (skb) {					\
-			m = (actcapi_msg *)skb_put(skb, l + 8); \
+			m = skb_put(skb, l + 8);		\
 			m->hdr.len = l + 8;			\
 			m->hdr.applicationID = 1;		\
 			m->hdr.cmd.cmd = c;			\
@@ -567,7 +567,7 @@ actcapi_data_b3_ind(act2000_card *card, struct sk_buff *skb) {
 		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
 		return 1;
 	}
-	msg = (actcapi_msg *)skb_put(skb, 11);
+	msg = skb_put(skb, 11);
 	msg->hdr.len = 11;
 	msg->hdr.applicationID = 1;
 	msg->hdr.cmd.cmd = 0x86;
diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index f4956c7..f5b8a1f 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -510,7 +510,7 @@ isar_rcv_frame(struct IsdnCardState *cs, struct BCState *bcs)
 	case L1_MODE_TRANS:
 	case L1_MODE_V32:
 		if ((skb = dev_alloc_skb(ireg->clsb))) {
-			rcv_mbox(cs, ireg, (u_char *)skb_put(skb, ireg->clsb));
+			rcv_mbox(cs, ireg, skb_put(skb, ireg->clsb));
 			skb_queue_tail(&bcs->rqueue, skb);
 			schedule_event(bcs, B_RCVBUFREADY);
 		} else {
@@ -575,7 +575,7 @@ isar_rcv_frame(struct IsdnCardState *cs, struct BCState *bcs)
 				debugl1(cs, "isar_rcv_frame: raw(%d) dle(%d)",
 					ireg->clsb, bcs->hw.isar.rcvidx);
 			if ((skb = dev_alloc_skb(bcs->hw.isar.rcvidx))) {
-				insert_dle((u_char *)skb_put(skb, bcs->hw.isar.rcvidx),
+				insert_dle(skb_put(skb, bcs->hw.isar.rcvidx),
 					   bcs->hw.isar.rcvbuf, ireg->clsb);
 				skb_queue_tail(&bcs->rqueue, skb);
 				schedule_event(bcs, B_RCVBUFREADY);
@@ -634,7 +634,7 @@ isar_rcv_frame(struct IsdnCardState *cs, struct BCState *bcs)
 				} else if (!(skb = dev_alloc_skb(len))) {
 					printk(KERN_WARNING "ISAR: receive out of memory\n");
 				} else {
-					insert_dle((u_char *)skb_put(skb, len),
+					insert_dle(skb_put(skb, len),
 						   bcs->hw.isar.rcvbuf,
 						   bcs->hw.isar.rcvidx);
 					skb_queue_tail(&bcs->rqueue, skb);
diff --git a/drivers/isdn/i4l/isdn_audio.c b/drivers/isdn/i4l/isdn_audio.c
index 78ce422..b6bcd1e 100644
--- a/drivers/isdn/i4l/isdn_audio.c
+++ b/drivers/isdn/i4l/isdn_audio.c
@@ -462,7 +462,7 @@ isdn_audio_goertzel(int *sample, modem_info *info)
 		       info->line);
 		return;
 	}
-	result = (int *) skb_put(skb, sizeof(int) * NCOEFF);
+	result = skb_put(skb, sizeof(int) * NCOEFF);
 	for (k = 0; k < NCOEFF; k++) {
 		sk = sk1 = sk2 = 0;
 		for (n = 0; n < DTMF_NPOINTS; n++) {
@@ -672,7 +672,7 @@ isdn_audio_put_dle_code(modem_info *info, u_char code)
 		       info->line);
 		return;
 	}
-	p = (char *) skb_put(skb, 2);
+	p = skb_put(skb, 2);
 	p[0] = 0x10;
 	p[1] = code;
 	ISDN_AUDIO_SKB_DLECOUNT(skb) = 0;
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index a694fb1..07d13f5 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -832,7 +832,7 @@ static void dvb_net_sec(struct net_device *dev,
 	skb->dev = dev;
 
 	/* copy L3 payload */
-	eth = (u8 *) skb_put(skb, pkt_len - 12 - 4 + 14 - snap);
+	eth = skb_put(skb, pkt_len - 12 - 4 + 14 - snap);
 	memcpy(eth + 14, pkt + 12 + snap, pkt_len - 12 - 4 - snap);
 
 	/* create ethernet header: */
diff --git a/drivers/media/radio/wl128x/fmdrv_common.c b/drivers/media/radio/wl128x/fmdrv_common.c
index 9fdcda6..b9d2bb1 100644
--- a/drivers/media/radio/wl128x/fmdrv_common.c
+++ b/drivers/media/radio/wl128x/fmdrv_common.c
@@ -420,7 +420,7 @@ static int fm_send_cmd(struct fmdev *fmdev, u8 fm_op, u16 type,	void *payload,
 	if (!test_bit(FM_FW_DW_INPROGRESS, &fmdev->flag) ||
 			test_bit(FM_INTTASK_RUNNING, &fmdev->flag)) {
 		/* Fill command header info */
-		hdr = (struct fm_cmd_msg_hdr *)skb_put(skb, FM_CMD_MSG_HDR_SIZE);
+		hdr = skb_put(skb, FM_CMD_MSG_HDR_SIZE);
 		hdr->hdr = FM_PKT_LOGICAL_CHAN_NUMBER;	/* 0x08 */
 
 		/* 3 (fm_opcode,rd_wr,dlen) + payload len) */
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index fbd54f0..1fe88bd 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -782,7 +782,7 @@ static int ad_lacpdu_send(struct port *port)
 	skb->protocol = PKT_TYPE_LACPDU;
 	skb->priority = TC_PRIO_CONTROL;
 
-	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
+	lacpdu_header = skb_put(skb, length);
 
 	ether_addr_copy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr);
 	/* Note: source address is set to be the member's PERMANENT address,
@@ -824,7 +824,7 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 	skb->network_header = skb->mac_header + ETH_HLEN;
 	skb->protocol = PKT_TYPE_LACPDU;
 
-	marker_header = (struct bond_marker_header *)skb_put(skb, length);
+	marker_header = skb_put(skb, length);
 
 	ether_addr_copy(marker_header->hdr.h_dest, lacpdu_mcast_addr);
 	/* Note: source address is set to be the member's PERMANENT address,
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index b0f6924..b8fc6a6 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -586,7 +586,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 
-	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
+	*cf = skb_put(skb, sizeof(struct can_frame));
 	memset(*cf, 0, sizeof(struct can_frame));
 
 	return skb;
@@ -614,7 +614,7 @@ struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 	can_skb_reserve(skb);
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 
-	*cfd = (struct canfd_frame *)skb_put(skb, sizeof(struct canfd_frame));
+	*cfd = skb_put(skb, sizeof(struct canfd_frame));
 	memset(*cfd, 0, sizeof(struct canfd_frame));
 
 	return skb;
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index bab01c84..eb4b9a1 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -638,7 +638,7 @@ static void emac_rx(struct net_device *dev)
 			if (!skb)
 				continue;
 			skb_reserve(skb, 2);
-			rdptr = (u8 *) skb_put(skb, rxlen - 4);
+			rdptr = skb_put(skb, rxlen - 4);
 
 			/* Read received packet from RX SRAM */
 			if (netif_msg_rx_status(db))
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index b96e4bf..60dfa85 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -949,7 +949,7 @@ static int send_pktsched_cmd(struct adapter *adap, int sched, int qidx, int lo,
 	if (!skb)
 		return -ENOMEM;
 
-	req = (struct mngt_pktsched_wr *)skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr_hi = htonl(V_WR_OP(FW_WROPCODE_MNGT));
 	req->mngt_opcode = FW_MNGTOPCODE_PKTSCHED_SET;
 	req->sched = sched;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index b0cbb2b..b30283c 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1096,7 +1096,7 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 		return;
 	}
 	skb->priority = CPL_PRIORITY_CONTROL;
-	req = (struct cpl_set_tcb_field *)skb_put(skb, sizeof(*req));
+	req = skb_put(skb, sizeof(*req));
 	req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, tid));
 	req->reply = 0;
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index c0a7813..1c66ab7 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1170,7 +1170,7 @@ dm9000_rx(struct net_device *dev)
 		if (GoodPacket &&
 		    ((skb = netdev_alloc_skb(dev, RxLen + 4)) != NULL)) {
 			skb_reserve(skb, 2);
-			rdptr = (u8 *) skb_put(skb, RxLen - 4);
+			rdptr = skb_put(skb, RxLen - 4);
 
 			/* Read received packet from RX SRAM */
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 13d00a3..6a3257e 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -416,7 +416,7 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 			 * 'skb_put()' points to the start of sk_buff
 			 * data area.
 			 */
-			data_ptr = (unsigned int *)skb_put(skb, pkt_len);
+			data_ptr = skb_put(skb, pkt_len);
 			for (i = 0; i < (pkt_len + 3) >> 2; i++)
 				*data_ptr++ = dnet_readl(bp, RX_DATA_FIFO);
 			skb->protocol = eth_type_trans(skb, dev);
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index ae6e30d..f702e37 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1287,7 +1287,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 		 */
 		skb_reserve(ringptr->skb, 2);
 
-		ringptr->skb->data = (u_char *) skb_put(ringptr->skb, MAX_ETHER_SIZE);
+		ringptr->skb->data = skb_put(ringptr->skb, MAX_ETHER_SIZE);
 
 		/* ringptr->pdl points to the beginning of the PDL, i.e. the PDH */
 		/* Note: 1st Fragment is used for the 4 byte packet status
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 1803afe..375500a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -772,7 +772,7 @@ int i40e_fcoe_handle_offload(struct i40e_ring *rx_ring,
 		    (fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA)) {
 			struct fcoe_crc_eof *crc = NULL;
 
-			crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
+			crc = skb_put(skb, sizeof(*crc));
 			crc->fcoe_eof = FC_EOF_T;
 		} else {
 			/* otherwise, drop the header only frame */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 631c603..78f42ae9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -491,7 +491,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
 	    (fctl & FC_FC_END_SEQ)) {
 		skb_linearize(skb);
-		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
+		crc = skb_put(skb, sizeof(*crc));
 		crc->fcoe_eof = FC_EOF_T;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index b66e03d..02d00f0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -63,8 +63,8 @@ static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
 
 	skb_reserve(skb, NET_IP_ALIGN);
 
-	ethh = (struct ethhdr *)skb_put(skb, sizeof(struct ethhdr));
-	packet	= (unsigned char *)skb_put(skb, packet_size);
+	ethh = skb_put(skb, sizeof(struct ethhdr));
+	packet = skb_put(skb, packet_size);
 	memcpy(ethh->h_dest, priv->dev->dev_addr, ETH_ALEN);
 	eth_zero_addr(ethh->h_source);
 	ethh->h_proto = htons(ETH_P_ARP);
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index f78909a..b530603 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -667,7 +667,7 @@ static void ks8842_rx_frame(struct net_device *netdev,
 			ks8842_update_rx_counters(netdev, status, len);
 
 			if (adapter->conf_flags & KS884X_16BIT) {
-				u16 *data16 = (u16 *)skb_put(skb, len);
+				u16 *data16 = skb_put(skb, len);
 				ks8842_select_bank(adapter, 17);
 				while (len > 0) {
 					*data16++ = ioread16(adapter->hw_addr +
@@ -677,7 +677,7 @@ static void ks8842_rx_frame(struct net_device *netdev,
 					len -= sizeof(u32);
 				}
 			} else {
-				u32 *data = (u32 *)skb_put(skb, len);
+				u32 *data = skb_put(skb, len);
 
 				ks8842_select_bank(adapter, 17);
 				while (len > 0) {
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index b605dfd5..25f6da2 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -414,8 +414,7 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 
 		/* Copy the payload in, incrementing the source address to
 		 * exercise the rss vectors */
-		payload = ((struct efx_loopback_payload *)
-			   skb_put(skb, sizeof(state->payload)));
+		payload = skb_put(skb, sizeof(state->payload));
 		memcpy(payload, &state->payload, sizeof(state->payload));
 		payload->ip.saddr = htonl(INADDR_LOOPBACK | (i << 2));
 
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 53fe200..3bd1a15 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1118,7 +1118,7 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 			dev_kfree_skb(skb);
 			return NULL;
 		}
-		(void)skb_put(nskb, skb->len);
+		skb_put(nskb, skb->len);
 		if (skb_is_gso(skb)) {
 			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
 			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index aa1dd92..445dcd7 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -884,7 +884,7 @@ static int pppoe_sendmsg(struct socket *sock, struct msghdr *m,
 	skb->priority = sk->sk_priority;
 	skb->protocol = cpu_to_be16(ETH_P_PPP_SES);
 
-	ph = (struct pppoe_hdr *)skb_put(skb, total_len + sizeof(struct pppoe_hdr));
+	ph = skb_put(skb, total_len + sizeof(struct pppoe_hdr));
 	start = (char *)&ph->tag[0];
 
 	error = memcpy_from_msg(start, m, total_len);
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 384d736..c8936d0 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -483,7 +483,7 @@ encapsulate:
 	/* maybe pad; then trailer */
 	if (!((skb->len + sizeof *trailer) & 0x01))
 		skb_put_uchar(skb, PAD_BYTE);
-	trailer = (struct nc_trailer *) skb_put(skb, sizeof *trailer);
+	trailer = skb_put(skb, sizeof *trailer);
 	put_unaligned(header->packet_id, &trailer->packet_id);
 #if 0
 	netdev_dbg(dev->net, "frame >tx h %d p %d id %d\n",
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 27a5f95..707c1de 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1479,7 +1479,7 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	skb_pull(reply, sizeof(struct ipv6hdr));
 	skb_set_transport_header(reply, 0);
 
-	na = (struct nd_msg *)skb_put(reply, sizeof(*na) + na_olen);
+	na = skb_put(reply, sizeof(*na) + na_olen);
 
 	/* Neighbor Advertisement */
 	memset(na, 0, sizeof(*na)+na_olen);
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 0d76455..6c47e44 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -228,7 +228,7 @@ static void ppp_tx_cp(struct net_device *dev, u16 pid, u8 code,
 	}
 	skb_reserve(skb, sizeof(struct hdlc_header));
 
-	cp = (struct cp_header *)skb_put(skb, sizeof(struct cp_header));
+	cp = skb_put(skb, sizeof(struct cp_header));
 	cp->code = code;
 	cp->id = id;
 	cp->len = htons(sizeof(struct cp_header) + magic_len + len);
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d0c97c2..7bddfef 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3333,7 +3333,7 @@ static void airo_handle_rx(struct airo_info *ai)
 	}
 
 	skb_reserve(skb, 2); /* This way the IP header is aligned */
-	buffer = (__le16 *) skb_put(skb, len + hdrlen);
+	buffer = skb_put(skb, len + hdrlen);
 	if (test_bit(FLAG_802_11, &ai->flags)) {
 		buffer[0] = fc;
 		bap_read(ai, buffer + 1, hdrlen - 2, BAP0);
@@ -3735,7 +3735,7 @@ static void mpi_receive_802_11(struct airo_info *ai)
 		ai->dev->stats.rx_dropped++;
 		goto badrx;
 	}
-	buffer = (u16*)skb_put (skb, len + hdrlen);
+	buffer = skb_put(skb, len + hdrlen);
 	memcpy ((char *)buffer, ptr, hdrlen);
 	ptr += hdrlen;
 	if (hdrlen == 24)
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index 81ba48d..ba178f5 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -321,7 +321,7 @@ void ath6kl_debug_fwlog_event(struct ath6kl *ar, const void *buf, size_t len)
 	if (!skb)
 		return;
 
-	slot = (struct ath6kl_fwlog_slot *) skb_put(skb, slot_len);
+	slot = skb_put(skb, slot_len);
 	slot->timestamp = cpu_to_le32(jiffies);
 	slot->length = cpu_to_le32(len);
 	memcpy(slot->payload, buf, len);
diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index ca1a18c..75c02a0 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -1274,8 +1274,7 @@ static int ath6kl_htc_pipe_conn_service(struct htc_target *target,
 		length = sizeof(struct htc_conn_service_msg);
 
 		/* assemble connect service message */
-		conn_msg = (struct htc_conn_service_msg *) skb_put(skb,
-								   length);
+		conn_msg = skb_put(skb, length);
 		if (conn_msg == NULL) {
 			WARN_ON_ONCE(1);
 			status = -EINVAL;
@@ -1504,8 +1503,7 @@ static int ath6kl_htc_pipe_start(struct htc_target *target)
 	skb = packet->skb;
 
 	/* assemble setup complete message */
-	setup = (struct htc_setup_comp_ext_msg *) skb_put(skb,
-							  sizeof(*setup));
+	setup = skb_put(skb, sizeof(*setup));
 	memset(setup, 0, sizeof(struct htc_setup_comp_ext_msg));
 	setup->msg_id = cpu_to_le16(HTC_MSG_SETUP_COMPLETE_EX_ID);
 
diff --git a/drivers/net/wireless/ath/ath9k/channel.c b/drivers/net/wireless/ath/ath9k/channel.c
index 2066650..0bb5b8a 100644
--- a/drivers/net/wireless/ath/ath9k/channel.c
+++ b/drivers/net/wireless/ath/ath9k/channel.c
@@ -1481,7 +1481,7 @@ void ath9k_beacon_add_noa(struct ath_softc *sc, struct ath_vif *avp,
 	hdr[1] = sizeof(noa_ie_hdr) + noa_len - 2;
 	hdr[7] = noa_len;
 
-	noa = (void *) skb_put(skb, noa_len);
+	noa = skb_put(skb, noa_len);
 	memset(noa, 0, noa_len);
 
 	noa->index = avp->noa_index;
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index d2408da..3d046c1 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -155,8 +155,7 @@ static int htc_config_pipe_credits(struct htc_target *target)
 	}
 	skb_reserve(skb, sizeof(struct htc_frame_hdr));
 
-	cp_msg = (struct htc_config_pipe_msg *)
-		skb_put(skb, sizeof(struct htc_config_pipe_msg));
+	cp_msg = skb_put(skb, sizeof(struct htc_config_pipe_msg));
 
 	cp_msg->message_id = cpu_to_be16(HTC_MSG_CONFIG_PIPE_ID);
 	cp_msg->pipe_id = USB_WLAN_TX_PIPE;
@@ -193,8 +192,7 @@ static int htc_setup_complete(struct htc_target *target)
 	}
 	skb_reserve(skb, sizeof(struct htc_frame_hdr));
 
-	comp_msg = (struct htc_comp_msg *)
-		skb_put(skb, sizeof(struct htc_comp_msg));
+	comp_msg = skb_put(skb, sizeof(struct htc_comp_msg));
 	comp_msg->msg_id = cpu_to_be16(HTC_MSG_SETUP_COMPLETE_ID);
 
 	target->htc_flags |= HTC_OP_START_WAIT;
@@ -262,8 +260,7 @@ int htc_connect_service(struct htc_target *target,
 
 	skb_reserve(skb, sizeof(struct htc_frame_hdr));
 
-	conn_msg = (struct htc_conn_svc_msg *)
-			skb_put(skb, sizeof(struct htc_conn_svc_msg));
+	conn_msg = skb_put(skb, sizeof(struct htc_conn_svc_msg));
 	conn_msg->service_id = cpu_to_be16(service_connreq->service_id);
 	conn_msg->msg_id = cpu_to_be16(HTC_MSG_CONNECT_SERVICE_ID);
 	conn_msg->con_flags = cpu_to_be16(service_connreq->con_flags);
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index ca533b4..51cec61 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -311,7 +311,7 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 	skb_reserve(skb, headroom);
 
 	if (cmd_len != 0 && cmd_buf != NULL) {
-		data = (u8 *) skb_put(skb, cmd_len);
+		data = skb_put(skb, cmd_len);
 		memcpy(data, cmd_buf, cmd_len);
 	}
 
diff --git a/drivers/net/wireless/ath/wil6210/wmi.c b/drivers/net/wireless/ath/wil6210/wmi.c
index 9fe2085..cb9f71d 100644
--- a/drivers/net/wireless/ath/wil6210/wmi.c
+++ b/drivers/net/wireless/ath/wil6210/wmi.c
@@ -523,7 +523,7 @@ static void wmi_evt_eapol_rx(struct wil6210_priv *wil, int id,
 		return;
 	}
 
-	eth = (struct ethhdr *)skb_put(skb, ETH_HLEN);
+	eth = skb_put(skb, ETH_HLEN);
 	ether_addr_copy(eth->h_dest, ndev->dev_addr);
 	ether_addr_copy(eth->h_source, evt->src_mac);
 	eth->h_proto = cpu_to_be16(ETH_P_PAE);
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index c995ace..f1a0a0b 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -998,7 +998,7 @@ static void prism2_send_mgmt(struct net_device *dev,
 
 	fc = type_subtype;
 	hdrlen = hostap_80211_get_hdrlen(cpu_to_le16(type_subtype));
-	hdr = (struct ieee80211_hdr *) skb_put(skb, hdrlen);
+	hdr = skb_put(skb, hdrlen);
 	if (body)
 		memcpy(skb_put(skb, body_len), body, body_len);
 
@@ -2364,7 +2364,7 @@ static void schedule_packet_send(local_info_t *local, struct sta_info *sta)
 		return;
 	}
 
-	hdr = (struct ieee80211_hdr *) skb_put(skb, 16);
+	hdr = skb_put(skb, 16);
 
 	/* Generate a fake pspoll frame to start packet delivery */
 	hdr->frame_control = cpu_to_le16(
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 01de1a3..5b1a7cd 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -1050,8 +1050,7 @@ int prism2_sta_send_mgmt(local_info_t *local, u8 *dst, u16 stype,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mgmt = (struct hostap_ieee80211_mgmt *)
-		skb_put(skb, IEEE80211_MGMT_HDR_LEN);
+	mgmt = skb_put(skb, IEEE80211_MGMT_HDR_LEN);
 	memset(mgmt, 0, IEEE80211_MGMT_HDR_LEN);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT | stype);
 	memcpy(mgmt->da, dst, ETH_ALEN);
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 39f3e6f..e873039 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -10373,7 +10373,7 @@ static void ipw_handle_promiscuous_tx(struct ipw_priv *priv,
 		if (!dst)
 			continue;
 
-		rt_hdr = (void *)skb_put(dst, sizeof(*rt_hdr));
+		rt_hdr = skb_put(dst, sizeof(*rt_hdr));
 
 		rt_hdr->it_version = PKTHDR_RADIOTAP_VERSION;
 		rt_hdr->it_pad = 0;
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/ipw2x00/libipw_tx.c
index e8c0398..abf3883 100644
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c
@@ -439,8 +439,7 @@ netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (rts_required) {
 		skb_frag = txb->fragments[0];
-		frag_hdr =
-		    (struct libipw_hdr_3addrqos *)skb_put(skb_frag, hdr_len);
+		frag_hdr = skb_put(skb_frag, hdr_len);
 
 		/*
 		 * Set header frame_ctl to the RTS.
@@ -470,8 +469,7 @@ netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_reserve(skb_frag,
 				    crypt->ops->extra_mpdu_prefix_len);
 
-		frag_hdr =
-		    (struct libipw_hdr_3addrqos *)skb_put(skb_frag, hdr_len);
+		frag_hdr = skb_put(skb_frag, hdr_len);
 		memcpy(frag_hdr, &header, hdr_len);
 
 		/* If this is not the last fragment, then add the MOREFRAGS
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index d5c0a1a..fc597dd 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -622,7 +622,7 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 	skb = dev_alloc_skb(sizeof(*pspoll));
 	if (!skb)
 		return;
-	pspoll = (void *) skb_put(skb, sizeof(*pspoll));
+	pspoll = skb_put(skb, sizeof(*pspoll));
 	pspoll->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					    IEEE80211_STYPE_PSPOLL |
 					    IEEE80211_FCTL_PM);
@@ -653,7 +653,7 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 	skb = dev_alloc_skb(sizeof(*hdr));
 	if (!skb)
 		return;
-	hdr = (void *) skb_put(skb, sizeof(*hdr) - ETH_ALEN);
+	hdr = skb_put(skb, sizeof(*hdr) - ETH_ALEN);
 	hdr->frame_control = cpu_to_le16(IEEE80211_FTYPE_DATA |
 					 IEEE80211_STYPE_NULLFUNC |
 					 (ps ? IEEE80211_FCTL_PM : 0));
@@ -861,7 +861,7 @@ static void mac80211_hwsim_monitor_ack(struct ieee80211_channel *chan,
 	if (skb == NULL)
 		return;
 
-	hdr = (struct hwsim_radiotap_ack_hdr *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->hdr.it_version = PKTHDR_RADIOTAP_VERSION;
 	hdr->hdr.it_pad = 0;
 	hdr->hdr.it_len = cpu_to_le16(sizeof(*hdr));
@@ -873,7 +873,7 @@ static void mac80211_hwsim_monitor_ack(struct ieee80211_channel *chan,
 	flags = IEEE80211_CHAN_2GHZ;
 	hdr->rt_chbitmask = cpu_to_le16(flags);
 
-	hdr11 = (struct ieee80211_hdr *) skb_put(skb, 10);
+	hdr11 = skb_put(skb, 10);
 	hdr11->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					   IEEE80211_STYPE_ACK);
 	hdr11->duration_id = cpu_to_le16(0);
diff --git a/drivers/net/wireless/mwifiex/11n_aggr.c b/drivers/net/wireless/mwifiex/11n_aggr.c
index 6183e25..c599e7b 100644
--- a/drivers/net/wireless/mwifiex/11n_aggr.c
+++ b/drivers/net/wireless/mwifiex/11n_aggr.c
@@ -62,7 +62,7 @@ mwifiex_11n_form_amsdu_pkt(struct sk_buff *skb_aggr,
 	};
 	struct tx_packet_hdr *tx_header;
 
-	tx_header = (void *)skb_put(skb_aggr, sizeof(*tx_header));
+	tx_header = skb_put(skb_aggr, sizeof(*tx_header));
 
 	/* Copy DA and SA */
 	dt_offset = 2 * ETH_ALEN;
diff --git a/drivers/net/wireless/mwifiex/tdls.c b/drivers/net/wireless/mwifiex/tdls.c
index 087d847..5fa3024 100644
--- a/drivers/net/wireless/mwifiex/tdls.c
+++ b/drivers/net/wireless/mwifiex/tdls.c
@@ -161,7 +161,7 @@ static void mwifiex_tdls_add_aid(struct mwifiex_private *priv,
 	u8 *pos;
 
 	assoc_rsp = (struct ieee_types_assoc_rsp *)&priv->assoc_rsp_buf;
-	pos = (void *)skb_put(skb, 4);
+	pos = skb_put(skb, 4);
 	*pos++ = WLAN_EID_AID;
 	*pos++ = 2;
 	*pos++ = le16_to_cpu(assoc_rsp->a_id);
@@ -175,7 +175,7 @@ static int mwifiex_tdls_add_vht_capab(struct mwifiex_private *priv,
 	struct ieee80211_vht_cap vht_cap;
 	u8 *pos;
 
-	pos = (void *)skb_put(skb, sizeof(struct ieee80211_vht_cap) + 2);
+	pos = skb_put(skb, sizeof(struct ieee80211_vht_cap) + 2);
 	*pos++ = WLAN_EID_VHT_CAPABILITY;
 	*pos++ = sizeof(struct ieee80211_vht_cap);
 
@@ -204,7 +204,7 @@ mwifiex_tdls_add_ht_oper(struct mwifiex_private *priv, const u8 *mac,
 		return -1;
 	}
 
-	pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_operation) + 2);
+	pos = skb_put(skb, sizeof(struct ieee80211_ht_operation) + 2);
 	*pos++ = WLAN_EID_HT_OPERATION;
 	*pos++ = sizeof(struct ieee80211_ht_operation);
 	ht_oper = (void *)pos;
@@ -262,7 +262,7 @@ static int mwifiex_tdls_add_vht_oper(struct mwifiex_private *priv,
 		ap_vht_cap = bss_desc->bcn_vht_cap;
 	}
 
-	pos = (void *)skb_put(skb, sizeof(struct ieee80211_vht_operation) + 2);
+	pos = skb_put(skb, sizeof(struct ieee80211_vht_operation) + 2);
 	*pos++ = WLAN_EID_VHT_OPERATION;
 	*pos++ = sizeof(struct ieee80211_vht_operation);
 	vht_oper = (struct ieee80211_vht_operation *)pos;
@@ -349,7 +349,7 @@ static void mwifiex_tdls_add_ext_capab(struct mwifiex_private *priv,
 {
 	struct ieee_types_extcap *extcap;
 
-	extcap = (void *)skb_put(skb, sizeof(struct ieee_types_extcap));
+	extcap = skb_put(skb, sizeof(struct ieee_types_extcap));
 	extcap->ieee_hdr.element_id = WLAN_EID_EXT_CAPABILITY;
 	extcap->ieee_hdr.len = 8;
 	memset(extcap->ext_capab, 0, 8);
@@ -361,7 +361,7 @@ static void mwifiex_tdls_add_ext_capab(struct mwifiex_private *priv,
 
 static void mwifiex_tdls_add_qos_capab(struct sk_buff *skb)
 {
-	u8 *pos = (void *)skb_put(skb, 3);
+	u8 *pos = skb_put(skb, 3);
 
 	*pos++ = WLAN_EID_QOS_CAPA;
 	*pos++ = 1;
@@ -377,7 +377,7 @@ mwifiex_tdls_add_wmm_param_ie(struct mwifiex_private *priv, struct sk_buff *skb)
 	u8 ac_be[] = {0x03, 0xa4, 0x00, 0x00};
 	u8 ac_bk[] = {0x27, 0xa4, 0x00, 0x00};
 
-	wmm = (void *)skb_put(skb, sizeof(*wmm));
+	wmm = skb_put(skb, sizeof(*wmm));
 	memset(wmm, 0, sizeof(*wmm));
 
 	wmm->element_id = WLAN_EID_VENDOR_SPECIFIC;
@@ -403,8 +403,8 @@ mwifiex_add_wmm_info_ie(struct mwifiex_private *priv, struct sk_buff *skb,
 {
 	u8 *buf;
 
-	buf = (void *)skb_put(skb, MWIFIEX_TDLS_WMM_INFO_SIZE +
-			      sizeof(struct ieee_types_header));
+	buf = skb_put(skb,
+		      MWIFIEX_TDLS_WMM_INFO_SIZE + sizeof(struct ieee_types_header));
 
 	*buf++ = WLAN_EID_VENDOR_SPECIFIC;
 	*buf++ = 7; /* len */
@@ -430,7 +430,7 @@ static int mwifiex_prep_tdls_encap_data(struct mwifiex_private *priv,
 
 	capab = priv->curr_bss_params.bss_descriptor.cap_info_bitmap;
 
-	tf = (void *)skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
+	tf = skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
 	memcpy(tf->da, peer, ETH_ALEN);
 	memcpy(tf->sa, priv->curr_addr, ETH_ALEN);
 	tf->ether_type = cpu_to_be16(ETH_P_TDLS);
@@ -449,7 +449,7 @@ static int mwifiex_prep_tdls_encap_data(struct mwifiex_private *priv,
 			return ret;
 		}
 
-		pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_cap);
 		ht_cap = (void *)pos;
@@ -487,7 +487,7 @@ static int mwifiex_prep_tdls_encap_data(struct mwifiex_private *priv,
 			return ret;
 		}
 
-		pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_cap);
 		ht_cap = (void *)pos;
@@ -567,7 +567,7 @@ mwifiex_tdls_add_link_ie(struct sk_buff *skb, const u8 *src_addr,
 {
 	struct ieee80211_tdls_lnkie *lnkid;
 
-	lnkid = (void *)skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
+	lnkid = skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
 	lnkid->ie_type = WLAN_EID_LINK_ID;
 	lnkid->ie_len = sizeof(struct ieee80211_tdls_lnkie) -
 			sizeof(struct ieee_types_header);
@@ -684,7 +684,7 @@ mwifiex_construct_tdls_action_frame(struct mwifiex_private *priv,
 
 	capab = priv->curr_bss_params.bss_descriptor.cap_info_bitmap;
 
-	mgmt = (void *)skb_put(skb, offsetof(struct ieee80211_mgmt, u));
+	mgmt = skb_put(skb, offsetof(struct ieee80211_mgmt, u));
 
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, peer, ETH_ALEN);
@@ -718,7 +718,7 @@ mwifiex_construct_tdls_action_frame(struct mwifiex_private *priv,
 			return ret;
 		}
 
-		pos = (void *)skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
+		pos = skb_put(skb, sizeof(struct ieee80211_ht_cap) + 2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_cap);
 		ht_cap = (void *)pos;
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index 275408e..7671ab1 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -205,7 +205,7 @@ static struct sk_buff *p54_alloc_skb(struct p54_common *priv, u16 hdr_flags,
 		return NULL;
 	skb_reserve(skb, priv->tx_hdr_len);
 
-	hdr = (struct p54_hdr *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->flags = cpu_to_le16(hdr_flags);
 	hdr->len = cpu_to_le16(payload_len);
 	hdr->type = cpu_to_le16(type);
@@ -235,8 +235,7 @@ int p54_download_eeprom(struct p54_common *priv, void *buf,
 
 	mutex_lock(&priv->eeprom_mutex);
 	priv->eeprom = buf;
-	eeprom_hdr = (struct p54_eeprom_lm86 *) skb_put(skb,
-		eeprom_hdr_size + len);
+	eeprom_hdr = skb_put(skb, eeprom_hdr_size + len);
 
 	if (priv->fw_var < 0x509) {
 		eeprom_hdr->v1.offset = cpu_to_le16(offset);
@@ -272,7 +271,7 @@ int p54_update_beacon_tim(struct p54_common *priv, u16 aid, bool set)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	tim = (struct p54_tim *) skb_put(skb, sizeof(*tim));
+	tim = skb_put(skb, sizeof(*tim));
 	tim->count = 1;
 	tim->entry[0] = cpu_to_le16(set ? (aid | 0x8000) : aid);
 	p54_tx(priv, skb);
@@ -289,7 +288,7 @@ int p54_sta_unlock(struct p54_common *priv, u8 *addr)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	sta = (struct p54_sta_unlock *)skb_put(skb, sizeof(*sta));
+	sta = skb_put(skb, sizeof(*sta));
 	memcpy(sta->addr, addr, ETH_ALEN);
 	p54_tx(priv, skb);
 	return 0;
@@ -309,7 +308,7 @@ int p54_tx_cancel(struct p54_common *priv, __le32 req_id)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	cancel = (struct p54_txcancel *)skb_put(skb, sizeof(*cancel));
+	cancel = skb_put(skb, sizeof(*cancel));
 	cancel->req_id = req_id;
 	p54_tx(priv, skb);
 	return 0;
@@ -326,7 +325,7 @@ int p54_setup_mac(struct p54_common *priv)
 	if (!skb)
 		return -ENOMEM;
 
-	setup = (struct p54_setup_mac *) skb_put(skb, sizeof(*setup));
+	setup = skb_put(skb, sizeof(*setup));
 	if (!(priv->hw->conf.flags & IEEE80211_CONF_IDLE)) {
 		switch (priv->mode) {
 		case NL80211_IFTYPE_STATION:
@@ -413,18 +412,18 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 	if (!skb)
 		return -ENOMEM;
 
-	head = (struct p54_scan_head *) skb_put(skb, sizeof(*head));
+	head = skb_put(skb, sizeof(*head));
 	memset(head->scan_params, 0, sizeof(head->scan_params));
 	head->mode = cpu_to_le16(mode);
 	head->dwell = cpu_to_le16(dwell);
 	head->freq = freq;
 
 	if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW) {
-		__le16 *pa_power_points = (__le16 *) skb_put(skb, 2);
+		__le16 *pa_power_points = skb_put(skb, 2);
 		*pa_power_points = cpu_to_le16(0x0c);
 	}
 
-	iq_autocal = (void *) skb_put(skb, sizeof(*iq_autocal));
+	iq_autocal = skb_put(skb, sizeof(*iq_autocal));
 	for (i = 0; i < priv->iq_autocal_len; i++) {
 		if (priv->iq_autocal[i].freq != freq)
 			continue;
@@ -437,9 +436,9 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 		goto err;
 
 	if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW)
-		body = (void *) skb_put(skb, sizeof(body->longbow));
+		body = skb_put(skb, sizeof(body->longbow));
 	else
-		body = (void *) skb_put(skb, sizeof(body->normal));
+		body = skb_put(skb, sizeof(body->normal));
 
 	for (i = 0; i < priv->output_limit->entries; i++) {
 		__le16 *entry_freq = (void *) (priv->output_limit->data +
@@ -500,25 +499,25 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 		goto err;
 
 	if ((priv->fw_var >= 0x500) && (priv->fw_var < 0x509)) {
-		rate = (void *) skb_put(skb, sizeof(*rate));
+		rate = skb_put(skb, sizeof(*rate));
 		rate->basic_rate_mask = cpu_to_le32(priv->basic_rate_mask);
 		for (i = 0; i < sizeof(rate->rts_rates); i++)
 			rate->rts_rates[i] = i;
 	}
 
-	rssi = (struct pda_rssi_cal_entry *) skb_put(skb, sizeof(*rssi));
+	rssi = skb_put(skb, sizeof(*rssi));
 	rssi_data = p54_rssi_find(priv, le16_to_cpu(freq));
 	rssi->mul = cpu_to_le16(rssi_data->mul);
 	rssi->add = cpu_to_le16(rssi_data->add);
 	if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW) {
 		/* Longbow frontend needs ever more */
-		rssi = (void *) skb_put(skb, sizeof(*rssi));
+		rssi = skb_put(skb, sizeof(*rssi));
 		rssi->mul = cpu_to_le16(rssi_data->longbow_unkn);
 		rssi->add = cpu_to_le16(rssi_data->longbow_unk2);
 	}
 
 	if (priv->fw_var >= 0x509) {
-		rate = (void *) skb_put(skb, sizeof(*rate));
+		rate = skb_put(skb, sizeof(*rate));
 		rate->basic_rate_mask = cpu_to_le32(priv->basic_rate_mask);
 		for (i = 0; i < sizeof(rate->rts_rates); i++)
 			rate->rts_rates[i] = i;
@@ -550,7 +549,7 @@ int p54_set_leds(struct p54_common *priv)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	led = (struct p54_led *) skb_put(skb, sizeof(*led));
+	led = skb_put(skb, sizeof(*led));
 	led->flags = cpu_to_le16(0x0003);
 	led->mask[0] = led->mask[1] = cpu_to_le16(priv->softled_state);
 	led->delay[0] = cpu_to_le16(1);
@@ -570,7 +569,7 @@ int p54_set_edcf(struct p54_common *priv)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	edcf = (struct p54_edcf *)skb_put(skb, sizeof(*edcf));
+	edcf = skb_put(skb, sizeof(*edcf));
 	if (priv->use_short_slot) {
 		edcf->slottime = 9;
 		edcf->sifs = 0x10;
@@ -615,7 +614,7 @@ int p54_set_ps(struct p54_common *priv)
 	if (!skb)
 		return -ENOMEM;
 
-	psm = (struct p54_psm *)skb_put(skb, sizeof(*psm));
+	psm = skb_put(skb, sizeof(*psm));
 	psm->mode = cpu_to_le16(mode);
 	psm->aid = cpu_to_le16(priv->aid);
 	for (i = 0; i < ARRAY_SIZE(psm->intervals); i++) {
@@ -644,7 +643,7 @@ int p54_init_xbow_synth(struct p54_common *priv)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	xbow = (struct p54_xbow_synth *)skb_put(skb, sizeof(*xbow));
+	xbow = skb_put(skb, sizeof(*xbow));
 	xbow->magic1 = cpu_to_le16(0x1);
 	xbow->magic2 = cpu_to_le16(0x2);
 	xbow->freq = cpu_to_le16(5390);
@@ -664,7 +663,7 @@ int p54_upload_key(struct p54_common *priv, u8 algo, int slot, u8 idx, u8 len,
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	rxkey = (struct p54_keycache *)skb_put(skb, sizeof(*rxkey));
+	rxkey = skb_put(skb, sizeof(*rxkey));
 	rxkey->entry = slot;
 	rxkey->key_id = idx;
 	rxkey->key_type = algo;
@@ -744,7 +743,7 @@ int p54_set_groupfilter(struct p54_common *priv)
 	if (!skb)
 		return -ENOMEM;
 
-	grp = (struct p54_group_address_table *)skb_put(skb, sizeof(*grp));
+	grp = skb_put(skb, sizeof(*grp));
 
 	on = !(priv->filter_flags & FIF_ALLMULTI) &&
 	     (priv->mc_maclist_num > 0 &&
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index 90fdb02..273184b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -187,7 +187,7 @@ void rt2x00debug_dump_frame(struct rt2x00_dev *rt2x00dev,
 		return;
 	}
 
-	dump_hdr = (struct rt2x00dump_hdr *)skb_put(skbcopy, sizeof(*dump_hdr));
+	dump_hdr = skb_put(skbcopy, sizeof(*dump_hdr));
 	dump_hdr->version = cpu_to_le32(DUMP_HEADER_VERSION);
 	dump_hdr->header_length = cpu_to_le32(sizeof(*dump_hdr));
 	dump_hdr->desc_length = cpu_to_le32(skbdesc->desc_len);
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 01f56c7..a590ce0 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1784,7 +1784,7 @@ static struct sk_buff *rtl_make_smps_action(struct ieee80211_hw *hw,
 		return NULL;
 
 	skb_reserve(skb, hw->extra_tx_headroom);
-	action_frame = (void *)skb_put(skb, 27);
+	action_frame = skb_put(skb, 27);
 	memset(action_frame, 0, 27);
 	memcpy(action_frame->da, da, ETH_ALEN);
 	memcpy(action_frame->sa, rtlefuse->dev_addr, ETH_ALEN);
@@ -1915,7 +1915,7 @@ struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
 		return NULL;
 
 	skb_reserve(skb, hw->extra_tx_headroom);
-	action_frame = (void *)skb_put(skb, 34);
+	action_frame = skb_put(skb, 34);
 	memset(action_frame, 0, 34);
 	memcpy(action_frame->sa, sa, ETH_ALEN);
 	memcpy(action_frame->da, rtlefuse->dev_addr, ETH_ALEN);
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index f46c9d7..aab7747 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -743,7 +743,7 @@ static void _rtl_pci_rx_to_mac80211(struct ieee80211_hw *hw,
 		if (likely(uskb)) {
 			memcpy(IEEE80211_SKB_RXCB(uskb), &rx_status,
 			       sizeof(rx_status));
-			pdata = (u8 *)skb_put(uskb, skb->len);
+			pdata = skb_put(uskb, skb->len);
 			memcpy(pdata, skb->data, skb->len);
 			dev_kfree_skb_any(skb);
 			ieee80211_rx_irqsafe(hw, uskb);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 29983bc..afd79f2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -720,8 +720,8 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet,
+               totalpacketlen);
 
 	if (cmd_send_packet)
 		rtstatus = cmd_send_packet(hw, skb);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
index 62ef820..346bb03 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
@@ -735,8 +735,8 @@ void rtl92d_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 	if (!skb) {
 		dlok = false;
 	} else {
-		memcpy((u8 *) skb_put(skb, totalpacketlen),
-			&reserved_page_packet, totalpacketlen);
+		memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet,
+		       totalpacketlen);
 		rtstatus = _rtl92d_cmd_send_packet(hw, skb);
 
 		if (rtstatus)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
index c5d4b80..751ecf4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
@@ -724,8 +724,8 @@ void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet,
+	       totalpacketlen);
 
 	b_dlok = true;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
index 331b158..7672920 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
@@ -195,8 +195,7 @@ static bool _rtl92s_firmware_downloadcode(struct ieee80211_hw *hw,
 		if (!skb)
 			return false;
 		skb_reserve(skb, extra_descoffset);
-		seg_ptr = (u8 *)skb_put(skb, (u32)(frag_length -
-					extra_descoffset));
+		seg_ptr = skb_put(skb, (u32)(frag_length - extra_descoffset));
 		memcpy(seg_ptr, code_virtual_address + frag_offset,
 		       (u32)(frag_length - extra_descoffset));
 
@@ -479,7 +478,7 @@ static u32 _rtl92s_fill_h2c_cmd(struct sk_buff *skb, u32 h2cbufferlen,
 			break;
 
 		/* Clear content */
-		ph2c_buffer = (u8 *)skb_put(skb, (u32)len);
+		ph2c_buffer = skb_put(skb, (u32)len);
 		memset((ph2c_buffer + totallen + tx_desclen), 0, len);
 
 		/* CMD len */
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
index b7c0d38..7ce7baa 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
@@ -471,8 +471,8 @@ void rtl8723e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet,
+               totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
index 69d4f0f..d76b970 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
@@ -465,8 +465,8 @@ void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet,
+               totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
index 95e9562..3f4d8b1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
@@ -1546,8 +1546,8 @@ out:
 		      &reserved_page_packet_8812[0], totalpacketlen);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet_8812, totalpacketlen);
+	memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet_8812,
+               totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
@@ -1671,8 +1671,8 @@ out:
 		      &reserved_page_packet_8821[0], totalpacketlen);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet_8821, totalpacketlen);
+	memcpy(skb_put(skb, totalpacketlen), &reserved_page_packet_8821,
+	       totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index 68919f8..d4899c8 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -1230,7 +1230,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	skb_reserve(skb, sizeof(*hdr) + WL1271_EXTRA_SPACE_MAX);
 
-	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
+	tmpl = skb_put(skb, sizeof(*tmpl));
 	memset(tmpl, 0, sizeof(*tmpl));
 
 	/* llc layer */
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 0be8079..6dc01a3 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -1373,7 +1373,7 @@ static struct sk_buff *wl12xx_alloc_dummy_packet(struct wl1271 *wl)
 
 	skb_reserve(skb, sizeof(struct wl1271_tx_hw_descr));
 
-	hdr = (struct ieee80211_hdr_3addr *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	memset(hdr, 0, sizeof(*hdr));
 	hdr->frame_control = cpu_to_le16(IEEE80211_FTYPE_DATA |
 					 IEEE80211_STYPE_NULLFUNC |
diff --git a/drivers/nfc/nfcwilink.c b/drivers/nfc/nfcwilink.c
index ce2e2cf..fdcf6ef 100644
--- a/drivers/nfc/nfcwilink.c
+++ b/drivers/nfc/nfcwilink.c
@@ -153,8 +153,7 @@ static int nfcwilink_get_bts_file_name(struct nfcwilink *drv, char *file_name)
 		return -ENOMEM;
 	}
 
-	cmd = (struct nci_vs_nfcc_info_cmd *)
-			skb_put(skb, sizeof(struct nci_vs_nfcc_info_cmd));
+	cmd = skb_put(skb, sizeof(struct nci_vs_nfcc_info_cmd));
 	cmd->gid = NCI_VS_NFCC_INFO_CMD_GID;
 	cmd->oid = NCI_VS_NFCC_INFO_CMD_OID;
 	cmd->plen = 0;
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 98d06d1..84dd76b 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -329,7 +329,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, struct fc_frame *fp)
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
 		cp = kmap_atomic(skb_frag_page(frag)) + frag->page_offset;
 	} else {
-		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+		cp = skb_put(skb, tlen);
 	}
 
 	memset(cp, 0, sizeof(*cp));
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index ec193a8..9b37cd1 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1646,7 +1646,7 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 		cp = kmap_atomic(skb_frag_page(frag))
 			+ frag->page_offset;
 	} else {
-		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+		cp = skb_put(skb, tlen);
 	}
 
 	memset(cp, 0, sizeof(*cp));
diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
index 34a1b1f..c150d9e 100644
--- a/drivers/scsi/fcoe/fcoe_ctlr.c
+++ b/drivers/scsi/fcoe/fcoe_ctlr.c
@@ -657,7 +657,7 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip, struct fc_lport *lport,
 
 	if (op != ELS_LS_RJT) {
 		dlen += sizeof(*mac);
-		mac = (struct fip_mac_desc *)skb_put(skb, sizeof(*mac));
+		mac = skb_put(skb, sizeof(*mac));
 		memset(mac, 0, sizeof(*mac));
 		mac->fd_desc.fip_dtype = FIP_DT_MAC;
 		mac->fd_desc.fip_dlen = sizeof(*mac) / FIP_BPW;
diff --git a/drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c b/drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c
index eecfa37..eddbead 100644
--- a/drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c
+++ b/drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c
@@ -1461,7 +1461,7 @@ static int ft1000_copy_up_pkt(struct net_device *dev)
 		info->stats.rx_errors++;
 		return FAILURE;
 	}
-	pbuffer = (u8 *)skb_put(skb, len + 12);
+	pbuffer = skb_put(skb, len + 12);
 
 	/* Pseudo header */
 	if (info->AsicID == ELECTRABUZZ_ID) {
diff --git a/drivers/staging/ft1000/ft1000-usb/ft1000_hw.c b/drivers/staging/ft1000/ft1000-usb/ft1000_hw.c
index e6fb066..f47f5b1 100644
--- a/drivers/staging/ft1000/ft1000-usb/ft1000_hw.c
+++ b/drivers/staging/ft1000/ft1000-usb/ft1000_hw.c
@@ -848,7 +848,7 @@ static int ft1000_copy_up_pkt(struct urb *urb)
 		return -1;
 	}
 
-	pbuffer = (u8 *)skb_put(skb, len + 12);
+	pbuffer = skb_put(skb, len + 12);
 
 	/* subtract the number of bytes read already */
 	ptemp = pbuffer;
diff --git a/drivers/staging/ozwpan/ozpd.c b/drivers/staging/ozwpan/ozpd.c
index 021d74a..d196cd9 100644
--- a/drivers/staging/ozwpan/ozpd.c
+++ b/drivers/staging/ozwpan/ozpd.c
@@ -430,7 +430,7 @@ static struct sk_buff *oz_build_frame(struct oz_pd *pd, struct oz_tx_frame *f)
 		goto fail;
 	/* Push the tail to the end of the area we are going to copy to.
 	 */
-	oz_hdr = (struct oz_hdr *)skb_put(skb, f->total_size);
+	oz_hdr = skb_put(skb, f->total_size);
 	f->hdr.last_pkt_num = pd->trigger_pkt_num & OZ_LAST_PN_MASK;
 	memcpy(oz_hdr, &f->hdr, sizeof(struct oz_hdr));
 	/* Copy the elements into the frame body.
@@ -589,7 +589,7 @@ static int oz_send_isoc_frame(struct oz_pd *pd)
 		kfree_skb(skb);
 		return -1;
 	}
-	oz_hdr = (struct oz_hdr *)skb_put(skb, total_size);
+	oz_hdr = skb_put(skb, total_size);
 	oz_hdr->control = (OZ_PROTOCOL_VERSION<<OZ_VERSION_SHIFT) | OZ_F_ISOC;
 	oz_hdr->last_pkt_num = pd->trigger_pkt_num & OZ_LAST_PN_MASK;
 	elt = (struct oz_elt *)(oz_hdr+1);
@@ -743,7 +743,7 @@ int oz_send_isoc_unit(struct oz_pd *pd, u8 ep_num, const u8 *data, int len)
 		/* For audio packet set priority to AC_VO */
 		skb->priority = 0x7;
 		size = sizeof(struct oz_hdr) + sizeof(struct oz_isoc_large);
-		oz_hdr = (struct oz_hdr *)skb_put(skb, size);
+		oz_hdr = skb_put(skb, size);
 	}
 	memcpy(skb_put(skb, len), data, len);
 	size += len;
diff --git a/drivers/staging/ozwpan/ozproto.c b/drivers/staging/ozwpan/ozproto.c
index 1ba24a2..41f99c1 100644
--- a/drivers/staging/ozwpan/ozproto.c
+++ b/drivers/staging/ozwpan/ozproto.c
@@ -87,7 +87,7 @@ static void oz_send_conn_rsp(struct oz_pd *pd, u8 status)
 		return;
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb_reset_network_header(skb);
-	oz_hdr = (struct oz_hdr *)skb_put(skb, sz);
+	oz_hdr = skb_put(skb, sz);
 	elt = (struct oz_elt *)(oz_hdr+1);
 	body = (struct oz_elt_connect_rsp *)(elt+1);
 	skb->dev = dev;
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index cda725a..d25bc2d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -1655,7 +1655,7 @@ static int amsdu_to_msdu(struct adapter *padapter, struct recv_frame *prframe)
 		sub_skb = dev_alloc_skb(nSubframe_Length + 12);
 		if (sub_skb) {
 			skb_reserve(sub_skb, 12);
-			data_ptr = (u8 *)skb_put(sub_skb, nSubframe_Length);
+			data_ptr = skb_put(sub_skb, nSubframe_Length);
 			memcpy(data_ptr, pdata, nSubframe_Length);
 		} else {
 			sub_skb = skb_clone(prframe->pkt, GFP_ATOMIC);
diff --git a/drivers/staging/rtl8192e/rtl819x_BAProc.c b/drivers/staging/rtl8192e/rtl819x_BAProc.c
index 26258ea..9286cfe 100644
--- a/drivers/staging/rtl8192e/rtl819x_BAProc.c
+++ b/drivers/staging/rtl8192e/rtl819x_BAProc.c
@@ -100,8 +100,7 @@ static struct sk_buff *rtllib_ADDBA(struct rtllib_device *ieee, u8 *Dst,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	BAReq = (struct rtllib_hdr_3addr *)skb_put(skb,
-		 sizeof(struct rtllib_hdr_3addr));
+	BAReq = skb_put(skb, sizeof(struct rtllib_hdr_3addr));
 
 	memcpy(BAReq->addr1, Dst, ETH_ALEN);
 	memcpy(BAReq->addr2, ieee->dev->dev_addr, ETH_ALEN);
@@ -109,7 +108,7 @@ static struct sk_buff *rtllib_ADDBA(struct rtllib_device *ieee, u8 *Dst,
 	memcpy(BAReq->addr3, ieee->current_network.bssid, ETH_ALEN);
 	BAReq->frame_ctl = cpu_to_le16(RTLLIB_STYPE_MANAGE_ACT);
 
-	tag = (u8 *)skb_put(skb, 9);
+	tag = skb_put(skb, 9);
 	*tag++ = ACT_CAT_BA;
 	*tag++ = type;
 	*tag++ = pBA->DialogToken;
@@ -164,15 +163,14 @@ static struct sk_buff *rtllib_DELBA(struct rtllib_device *ieee, u8 *dst,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	Delba = (struct rtllib_hdr_3addr *) skb_put(skb,
-		 sizeof(struct rtllib_hdr_3addr));
+	Delba = skb_put(skb, sizeof(struct rtllib_hdr_3addr));
 
 	memcpy(Delba->addr1, dst, ETH_ALEN);
 	memcpy(Delba->addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memcpy(Delba->addr3, ieee->current_network.bssid, ETH_ALEN);
 	Delba->frame_ctl = cpu_to_le16(RTLLIB_STYPE_MANAGE_ACT);
 
-	tag = (u8 *)skb_put(skb, 6);
+	tag = skb_put(skb, 6);
 
 	*tag++ = ACT_CAT_BA;
 	*tag++ = ACT_DELBA;
diff --git a/drivers/staging/rtl8192e/rtllib_rx.c b/drivers/staging/rtl8192e/rtllib_rx.c
index fe3e7e12..fbe9669 100644
--- a/drivers/staging/rtl8192e/rtllib_rx.c
+++ b/drivers/staging/rtl8192e/rtllib_rx.c
@@ -775,7 +775,7 @@ static u8 parse_subframe(struct rtllib_device *ieee, struct sk_buff *skb,
 		if (!sub_skb)
 			return 0;
 		skb_reserve(sub_skb, 12);
-		data_ptr = (u8 *)skb_put(sub_skb, skb->len);
+		data_ptr = skb_put(sub_skb, skb->len);
 		memcpy(data_ptr, skb->data, skb->len);
 		sub_skb->dev = ieee->dev;
 
@@ -828,7 +828,7 @@ static u8 parse_subframe(struct rtllib_device *ieee, struct sk_buff *skb,
 		if (!sub_skb)
 			return 0;
 		skb_reserve(sub_skb, 12);
-		data_ptr = (u8 *)skb_put(sub_skb, nSubframe_Length);
+		data_ptr = skb_put(sub_skb, nSubframe_Length);
 		memcpy(data_ptr, skb->data, nSubframe_Length);
 
 		sub_skb->dev = ieee->dev;
diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/staging/rtl8192e/rtllib_softmac.c
index 23b7a4c..17e9953 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac.c
@@ -365,8 +365,7 @@ static inline struct sk_buff *rtllib_probe_req(struct rtllib_device *ieee)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	req = (struct rtllib_probe_request *) skb_put(skb,
-	      sizeof(struct rtllib_probe_request));
+	req = skb_put(skb, sizeof(struct rtllib_probe_request));
 	req->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_PROBE_REQ);
 	req->header.duration_id = 0;
 
@@ -374,7 +373,7 @@ static inline struct sk_buff *rtllib_probe_req(struct rtllib_device *ieee)
 	memcpy(req->header.addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memset(req->header.addr3, 0xff, ETH_ALEN);
 
-	tag = (u8 *) skb_put(skb, len + 2 + rate_len);
+	tag = skb_put(skb, len + 2 + rate_len);
 
 	*tag++ = MFIE_TYPE_SSID;
 	*tag++ = len;
@@ -806,8 +805,7 @@ inline struct sk_buff *rtllib_authentication_req(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	auth = (struct rtllib_authentication *)
-		skb_put(skb, sizeof(struct rtllib_authentication));
+	auth = skb_put(skb, sizeof(struct rtllib_authentication));
 
 	auth->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_AUTH);
 	if (challengelen)
@@ -905,8 +903,7 @@ static struct sk_buff *rtllib_probe_resp(struct rtllib_device *ieee, u8 *dest)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	beacon_buf = (struct rtllib_probe_response *) skb_put(skb,
-		     (beacon_size - ieee->tx_headroom));
+	beacon_buf = skb_put(skb, (beacon_size - ieee->tx_headroom));
 	memcpy(beacon_buf->header.addr1, dest, ETH_ALEN);
 	memcpy(beacon_buf->header.addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memcpy(beacon_buf->header.addr3, ieee->current_network.bssid, ETH_ALEN);
@@ -1000,8 +997,7 @@ static struct sk_buff *rtllib_assoc_resp(struct rtllib_device *ieee, u8 *dest)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	assoc = (struct rtllib_assoc_response_frame *)
-		skb_put(skb, sizeof(struct rtllib_assoc_response_frame));
+	assoc = skb_put(skb, sizeof(struct rtllib_assoc_response_frame));
 
 	assoc->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_ASSOC_RESP);
 	memcpy(assoc->header.addr1, dest, ETH_ALEN);
@@ -1032,7 +1028,7 @@ static struct sk_buff *rtllib_assoc_resp(struct rtllib_device *ieee, u8 *dest)
 	else
 		ieee->assoc_id++;
 
-	tag = (u8 *) skb_put(skb, rate_len);
+	tag = skb_put(skb, rate_len);
 	rtllib_MFIE_Brate(ieee, &tag);
 	rtllib_MFIE_Grate(ieee, &tag);
 
@@ -1054,8 +1050,7 @@ static struct sk_buff *rtllib_auth_resp(struct rtllib_device *ieee, int status,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	auth = (struct rtllib_authentication *)
-		skb_put(skb, sizeof(struct rtllib_authentication));
+	auth = skb_put(skb, sizeof(struct rtllib_authentication));
 
 	auth->status = cpu_to_le16(status);
 	auth->transaction = cpu_to_le16(2);
@@ -1081,8 +1076,7 @@ static struct sk_buff *rtllib_null_func(struct rtllib_device *ieee, short pwr)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct rtllib_hdr_3addr *)skb_put(skb,
-	      sizeof(struct rtllib_hdr_3addr));
+	hdr = skb_put(skb, sizeof(struct rtllib_hdr_3addr));
 
 	memcpy(hdr->addr1, ieee->current_network.bssid, ETH_ALEN);
 	memcpy(hdr->addr2, ieee->dev->dev_addr, ETH_ALEN);
@@ -1108,8 +1102,7 @@ static struct sk_buff *rtllib_pspoll_func(struct rtllib_device *ieee)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct rtllib_pspoll_hdr *)skb_put(skb,
-	      sizeof(struct rtllib_pspoll_hdr));
+	hdr = skb_put(skb, sizeof(struct rtllib_pspoll_hdr));
 
 	memcpy(hdr->bssid, ieee->current_network.bssid, ETH_ALEN);
 	memcpy(hdr->ta, ieee->dev->dev_addr, ETH_ALEN);
@@ -1258,8 +1251,7 @@ inline struct sk_buff *rtllib_association_req(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct rtllib_assoc_request_frame *)
-		skb_put(skb, sizeof(struct rtllib_assoc_request_frame) + 2);
+	hdr = skb_put(skb, sizeof(struct rtllib_assoc_request_frame) + 2);
 
 
 	hdr->header.frame_ctl = RTLLIB_STYPE_ASSOC_REQ;
@@ -3512,8 +3504,7 @@ inline struct sk_buff *rtllib_disauth_skb(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	disauth = (struct rtllib_disauth *) skb_put(skb,
-		  sizeof(struct rtllib_disauth));
+	disauth = skb_put(skb, sizeof(struct rtllib_disauth));
 	disauth->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_DEAUTH);
 	disauth->header.duration_id = 0;
 
@@ -3539,8 +3530,7 @@ inline struct sk_buff *rtllib_disassociate_skb(struct rtllib_network *beacon,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	disass = (struct rtllib_disassoc *) skb_put(skb,
-					 sizeof(struct rtllib_disassoc));
+	disass = skb_put(skb, sizeof(struct rtllib_disassoc));
 	disass->header.frame_ctl = cpu_to_le16(RTLLIB_STYPE_DISASSOC);
 	disass->header.duration_id = 0;
 
diff --git a/drivers/staging/rtl8192e/rtllib_tx.c b/drivers/staging/rtl8192e/rtllib_tx.c
index 3b15963..560654a 100644
--- a/drivers/staging/rtl8192e/rtllib_tx.c
+++ b/drivers/staging/rtl8192e/rtllib_tx.c
@@ -815,8 +815,7 @@ int rtllib_xmit_inter(struct sk_buff *skb, struct net_device *dev)
 			} else {
 				tcb_desc->bHwSec = 0;
 			}
-			frag_hdr = (struct rtllib_hdr_3addrqos *)
-				   skb_put(skb_frag, hdr_len);
+			frag_hdr = skb_put(skb_frag, hdr_len);
 			memcpy(frag_hdr, &header, hdr_len);
 
 			/* If this is not the last fragment, then add the
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
index 9fbb53d..3ee0334 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
@@ -848,7 +848,7 @@ static u8 parse_subframe(struct sk_buff *skb,
 			if (!sub_skb)
 				return 0;
 			skb_reserve(sub_skb, 12);
-			data_ptr = (u8 *)skb_put(sub_skb, nSubframe_Length);
+			data_ptr = skb_put(sub_skb, nSubframe_Length);
 			memcpy(data_ptr, skb->data, nSubframe_Length);
 #endif
 			rxb->subframes[rxb->nr_subframes++] = sub_skb;
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
index c238881..c05fb9e 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
@@ -339,7 +339,7 @@ inline struct sk_buff *ieee80211_probe_req(struct ieee80211_device *ieee)
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	req = (struct ieee80211_probe_request *) skb_put(skb,sizeof(struct ieee80211_probe_request));
+	req = skb_put(skb, sizeof(struct ieee80211_probe_request));
 	req->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_PROBE_REQ);
 	req->header.duration_id = 0; //FIXME: is this OK ?
 
@@ -347,7 +347,7 @@ inline struct sk_buff *ieee80211_probe_req(struct ieee80211_device *ieee)
 	memcpy(req->header.addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memset(req->header.addr3, 0xff, ETH_ALEN);
 
-	tag = (u8 *) skb_put(skb,len+2+rate_len);
+	tag = skb_put(skb, len + 2 + rate_len);
 
 	*tag++ = MFIE_TYPE_SSID;
 	*tag++ = len;
@@ -657,8 +657,7 @@ inline struct sk_buff *ieee80211_authentication_req(struct ieee80211_network *be
 	if (!skb) return NULL;
 
 	skb_reserve(skb, ieee->tx_headroom);
-	auth = (struct ieee80211_authentication *)
-		skb_put(skb, sizeof(struct ieee80211_authentication));
+	auth = skb_put(skb, sizeof(struct ieee80211_authentication));
 
 	auth->header.frame_ctl = IEEE80211_STYPE_AUTH;
 	if (challengelen) auth->header.frame_ctl |= IEEE80211_FCTL_WEP;
@@ -763,7 +762,7 @@ static struct sk_buff *ieee80211_probe_resp(struct ieee80211_device *ieee, u8 *d
 	if (!skb)
 		return NULL;
 	skb_reserve(skb, ieee->tx_headroom);
-	beacon_buf = (struct ieee80211_probe_response *) skb_put(skb, (beacon_size - ieee->tx_headroom));
+	beacon_buf = skb_put(skb, (beacon_size - ieee->tx_headroom));
 	memcpy (beacon_buf->header.addr1, dest,ETH_ALEN);
 	memcpy (beacon_buf->header.addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memcpy (beacon_buf->header.addr3, ieee->current_network.bssid, ETH_ALEN);
@@ -859,8 +858,7 @@ static struct sk_buff *ieee80211_assoc_resp(struct ieee80211_device *ieee,
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	assoc = (struct ieee80211_assoc_response_frame *)
-		skb_put(skb, sizeof(struct ieee80211_assoc_response_frame));
+	assoc = skb_put(skb, sizeof(struct ieee80211_assoc_response_frame));
 
 	assoc->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_ASSOC_RESP);
 	memcpy(assoc->header.addr1, dest,ETH_ALEN);
@@ -887,7 +885,7 @@ static struct sk_buff *ieee80211_assoc_resp(struct ieee80211_device *ieee,
 	if (ieee->assoc_id == 0x2007) ieee->assoc_id=0;
 	else ieee->assoc_id++;
 
-	tag = (u8 *) skb_put(skb, rate_len);
+	tag = skb_put(skb, rate_len);
 
 	ieee80211_MFIE_Brate(ieee, &tag);
 	ieee80211_MFIE_Grate(ieee, &tag);
@@ -935,7 +933,7 @@ static struct sk_buff *ieee80211_null_func(struct ieee80211_device *ieee,
 	if (!skb)
 		return NULL;
 
-	hdr = (struct ieee80211_hdr_3addr *)skb_put(skb,sizeof(struct ieee80211_hdr_3addr));
+	hdr = skb_put(skb, sizeof(struct ieee80211_hdr_3addr));
 
 	memcpy(hdr->addr1, ieee->current_network.bssid, ETH_ALEN);
 	memcpy(hdr->addr2, ieee->dev->dev_addr, ETH_ALEN);
@@ -1079,8 +1077,7 @@ inline struct sk_buff *ieee80211_association_req(struct ieee80211_network *beaco
 
 	skb_reserve(skb, ieee->tx_headroom);
 
-	hdr = (struct ieee80211_assoc_request_frame *)
-		skb_put(skb, sizeof(struct ieee80211_assoc_request_frame)+2);
+	hdr = skb_put(skb, sizeof(struct ieee80211_assoc_request_frame) + 2);
 
 
 	hdr->header.frame_ctl = IEEE80211_STYPE_ASSOC_REQ;
@@ -3118,7 +3115,7 @@ inline struct sk_buff *ieee80211_disassociate_skb(
 	if (!skb)
 		return NULL;
 
-	disass = (struct ieee80211_disassoc *) skb_put(skb,sizeof(struct ieee80211_disassoc));
+	disass = skb_put(skb, sizeof(struct ieee80211_disassoc));
 	disass->header.frame_ctl = cpu_to_le16(IEEE80211_STYPE_DISASSOC);
 	disass->header.duration_id = 0;
 
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
index 9f68c65..85cdea6 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
@@ -787,7 +787,7 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 			{
 				tcb_desc->bHwSec = 0;
 			}
-			frag_hdr = (struct ieee80211_hdr_3addrqos *)skb_put(skb_frag, hdr_len);
+			frag_hdr = skb_put(skb_frag, hdr_len);
 			memcpy(frag_hdr, &header, hdr_len);
 
 			/* If this is not the last fragment, then add the MOREFRAGS
diff --git a/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c b/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c
index 618d2cb..06d3fb1 100644
--- a/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c
+++ b/drivers/staging/rtl8192u/ieee80211/rtl819x_BAProc.c
@@ -130,7 +130,7 @@ static struct sk_buff *ieee80211_ADDBA(struct ieee80211_device *ieee, u8 *Dst, P
 	memset(skb->data, 0, sizeof( struct ieee80211_hdr_3addr));	//I wonder whether it's necessary. Apparently kernel will not do it when alloc a skb.
 	skb_reserve(skb, ieee->tx_headroom);
 
-	BAReq = ( struct ieee80211_hdr_3addr *) skb_put(skb,sizeof( struct ieee80211_hdr_3addr));
+	BAReq = skb_put(skb, sizeof(struct ieee80211_hdr_3addr));
 
 	memcpy(BAReq->addr1, Dst, ETH_ALEN);
 	memcpy(BAReq->addr2, ieee->dev->dev_addr, ETH_ALEN);
@@ -140,7 +140,7 @@ static struct sk_buff *ieee80211_ADDBA(struct ieee80211_device *ieee, u8 *Dst, P
 	BAReq->frame_ctl = cpu_to_le16(IEEE80211_STYPE_MANAGE_ACT); //action frame
 
 	//tag += sizeof( struct ieee80211_hdr_3addr); //move to action field
-	tag = (u8 *)skb_put(skb, 9);
+	tag = skb_put(skb, 9);
 	*tag ++= ACT_CAT_BA;
 	*tag ++= type;
 	// Dialog Token
@@ -217,14 +217,14 @@ static struct sk_buff *ieee80211_DELBA(
 //	memset(skb->data, 0, len+sizeof( struct ieee80211_hdr_3addr));
 	skb_reserve(skb, ieee->tx_headroom);
 
-	Delba = ( struct ieee80211_hdr_3addr *) skb_put(skb,sizeof( struct ieee80211_hdr_3addr));
+	Delba = skb_put(skb, sizeof(struct ieee80211_hdr_3addr));
 
 	memcpy(Delba->addr1, dst, ETH_ALEN);
 	memcpy(Delba->addr2, ieee->dev->dev_addr, ETH_ALEN);
 	memcpy(Delba->addr3, ieee->current_network.bssid, ETH_ALEN);
 	Delba->frame_ctl = cpu_to_le16(IEEE80211_STYPE_MANAGE_ACT); //action frame
 
-	tag = (u8 *)skb_put(skb, 6);
+	tag = skb_put(skb, 6);
 
 	*tag ++= ACT_CAT_BA;
 	*tag ++= ACT_DELBA;
diff --git a/drivers/staging/rtl8712/rtl8712_recv.c b/drivers/staging/rtl8712/rtl8712_recv.c
index 50227b5..2ffe948 100644
--- a/drivers/staging/rtl8712/rtl8712_recv.c
+++ b/drivers/staging/rtl8712/rtl8712_recv.c
@@ -362,7 +362,7 @@ static int amsdu_to_msdu(struct _adapter *padapter, union recv_frame *prframe)
 		if (!sub_skb)
 			break;
 		skb_reserve(sub_skb, 12);
-		data_ptr = (u8 *)skb_put(sub_skb, nSubframe_Length);
+		data_ptr = skb_put(sub_skb, nSubframe_Length);
 		memcpy(data_ptr, pdata, nSubframe_Length);
 		subframes[nr_subframes++] = sub_skb;
 		if (nr_subframes >= MAX_SUBFRAME_COUNT) {
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index bdcda9f..7a6c2d7 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -933,17 +933,17 @@ static struct sk_buff *package_for_tx(struct f_ncm *ncm)
 	}
 
 	/* Insert NDP alignment. */
-	ntb_iter = (void *) skb_put(skb2, ndp_pad);
+	ntb_iter = skb_put(skb2, ndp_pad);
 	memset(ntb_iter, 0, ndp_pad);
 
 	/* Copy NTB across. */
-	ntb_iter = (void *) skb_put(skb2, ncm->skb_tx_ndp->len);
+	ntb_iter = skb_put(skb2, ncm->skb_tx_ndp->len);
 	memcpy(ntb_iter, ncm->skb_tx_ndp->data, ncm->skb_tx_ndp->len);
 	dev_kfree_skb_any(ncm->skb_tx_ndp);
 	ncm->skb_tx_ndp = NULL;
 
 	/* Insert zero'd datagram. */
-	ntb_iter = (void *) skb_put(skb2, dgram_idx_len);
+	ntb_iter = skb_put(skb2, dgram_idx_len);
 	memset(ntb_iter, 0, dgram_idx_len);
 
 	return skb2;
@@ -978,7 +978,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 			crc = ~crc32_le(~0,
 					skb->data,
 					skb->len);
-			crc_pos = (void *) skb_put(skb, sizeof(uint32_t));
+			crc_pos = skb_put(skb, sizeof(uint32_t));
 			put_unaligned_le32(crc, crc_pos);
 		}
 
@@ -1008,7 +1008,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 			if (!ncm->skb_tx_data)
 				goto err;
 
-			ntb_data = (void *) skb_put(ncm->skb_tx_data, ncb_len);
+			ntb_data = skb_put(ncm->skb_tx_data, ncb_len);
 			memset(ntb_data, 0, ncb_len);
 			/* dwSignature */
 			put_unaligned_le32(opts->nth_sign, ntb_data);
@@ -1026,8 +1026,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 						    GFP_ATOMIC);
 			if (!ncm->skb_tx_ndp)
 				goto err;
-			ntb_ndp = (void *) skb_put(ncm->skb_tx_ndp,
-						    opts->ndp_size);
+			ntb_ndp = skb_put(ncm->skb_tx_ndp, opts->ndp_size);
 			memset(ntb_ndp, 0, ncb_len);
 			/* dwSignature */
 			put_unaligned_le32(ncm->ndp_sign, ntb_ndp);
@@ -1045,7 +1044,7 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 			      HRTIMER_MODE_REL);
 
 		/* Add the datagram position entries */
-		ntb_ndp = (void *) skb_put(ncm->skb_tx_ndp, dgram_idx_len);
+		ntb_ndp = skb_put(ncm->skb_tx_ndp, dgram_idx_len);
 		memset(ntb_ndp, 0, dgram_idx_len);
 
 		ncb_len = ncm->skb_tx_data->len;
@@ -1059,9 +1058,9 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 		ncm->ndp_dgram_count++;
 
 		/* Add the new data to the skb */
-		ntb_data = (void *) skb_put(ncm->skb_tx_data, dgram_pad);
+		ntb_data = skb_put(ncm->skb_tx_data, dgram_pad);
 		memset(ntb_data, 0, dgram_pad);
-		ntb_data = (void *) skb_put(ncm->skb_tx_data, skb->len);
+		ntb_data = skb_put(ncm->skb_tx_data, skb->len);
 		memcpy(ntb_data, skb->data, skb->len);
 		dev_kfree_skb_any(skb);
 		skb = NULL;
diff --git a/lib/nlattr.c b/lib/nlattr.c
index f5907d2..01d54be 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -344,7 +344,7 @@ struct nlattr *__nla_reserve(struct sk_buff *skb, int attrtype, int attrlen)
 {
 	struct nlattr *nla;
 
-	nla = (struct nlattr *) skb_put(skb, nla_total_size(attrlen));
+	nla = skb_put(skb, nla_total_size(attrlen));
 	nla->nla_type = attrtype;
 	nla->nla_len = nla_attr_size(attrlen);
 
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 3b7ad43..a2db716 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1647,7 +1647,7 @@ static int atalk_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	SOCK_DEBUG(sk, "SK %p: Begin build.\n", sk);
 
-	ddp = (struct ddpehdr *)skb_put(skb, sizeof(struct ddpehdr));
+	ddp = skb_put(skb, sizeof(struct ddpehdr));
 	ddp->deh_len_hops  = htons(len + sizeof(*ddp));
 	ddp->deh_dnet  = usat->sat_addr.s_net;
 	ddp->deh_snet  = at->src_net;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 17e55df..e035fec 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -60,7 +60,7 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 	skb = alloc_skb(sizeof(struct atmarp_ctrl), GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
-	ctrl = (struct atmarp_ctrl *)skb_put(skb, sizeof(struct atmarp_ctrl));
+	ctrl = skb_put(skb, sizeof(struct atmarp_ctrl));
 	ctrl->type = type;
 	ctrl->itf_num = itf;
 	ctrl->ip = ip;
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 4fd6af4..8ec2be9 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -150,7 +150,7 @@ void sigd_enq2(struct atm_vcc *vcc, enum atmsvc_msg_type type,
 	pr_debug("%d (0x%p)\n", (int)type, vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
 		schedule();
-	msg = (struct atmsvc_msg *)skb_put(skb, sizeof(struct atmsvc_msg));
+	msg = skb_put(skb, sizeof(struct atmsvc_msg));
 	memset(msg, 0, sizeof(*msg));
 	msg->type = type;
 	*(struct atm_vcc **) &msg->vcc = vcc;
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 161ef8f..e05f6e1 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -186,7 +186,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 
 	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, ETH_HLEN);
-	icmp_header = (struct batadv_icmp_header *)skb_put(skb, packet_len);
+	icmp_header = skb_put(skb, packet_len);
 
 	if (copy_from_user(icmp_header, buff, packet_len)) {
 		len = -EFAULT;
diff --git a/net/bluetooth/hci_request.c b/net/bluetooth/hci_request.c
index d6025d6..20ec2e0 100644
--- a/net/bluetooth/hci_request.c
+++ b/net/bluetooth/hci_request.c
@@ -89,7 +89,7 @@ struct sk_buff *hci_prepare_cmd(struct hci_dev *hdev, u16 opcode, u32 plen,
 	if (!skb)
 		return NULL;
 
-	hdr = (struct hci_command_hdr *) skb_put(skb, HCI_COMMAND_HDR_SIZE);
+	hdr = skb_put(skb, HCI_COMMAND_HDR_SIZE);
 	hdr->opcode = cpu_to_le16(opcode);
 	hdr->plen   = plen;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 7b4f65b..233b975 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -312,7 +312,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 		if (!skb)
 			return NULL;
 
-		ni = (void *) skb_put(skb, HCI_MON_NEW_INDEX_SIZE);
+		ni = skb_put(skb, HCI_MON_NEW_INDEX_SIZE);
 		ni->type = hdev->dev_type;
 		ni->bus = hdev->bus;
 		bacpy(&ni->bdaddr, &hdev->bdaddr);
@@ -374,11 +374,11 @@ static void hci_si_event(struct hci_dev *hdev, int type, int dlen, void *data)
 	if (!skb)
 		return;
 
-	hdr = (void *) skb_put(skb, HCI_EVENT_HDR_SIZE);
+	hdr = skb_put(skb, HCI_EVENT_HDR_SIZE);
 	hdr->evt  = HCI_EV_STACK_INTERNAL;
 	hdr->plen = sizeof(*ev) + dlen;
 
-	ev  = (void *) skb_put(skb, sizeof(*ev) + dlen);
+	ev = skb_put(skb, sizeof(*ev) + dlen);
 	ev->type = type;
 	memcpy(ev->data, data, dlen);
 
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index dad4197..d81049d 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1037,7 +1037,7 @@ static struct sk_buff *l2cap_create_sframe_pdu(struct l2cap_chan *chan,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->len = cpu_to_le16(hlen - L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 
@@ -2175,10 +2175,10 @@ static struct sk_buff *l2cap_create_connless_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len + L2CAP_PSMLEN_SIZE);
-	put_unaligned(chan->psm, (__le16 *) skb_put(skb, L2CAP_PSMLEN_SIZE));
+	put_unaligned(chan->psm, skb_put(skb, L2CAP_PSMLEN_SIZE));
 
 	err = l2cap_skbuff_fromiovec(chan, msg, len, count, skb);
 	if (unlikely(err < 0)) {
@@ -2206,7 +2206,7 @@ static struct sk_buff *l2cap_create_basic_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len);
 
@@ -2248,7 +2248,7 @@ static struct sk_buff *l2cap_create_iframe_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 
@@ -2366,7 +2366,7 @@ static struct sk_buff *l2cap_create_le_flowctl_pdu(struct l2cap_chan *chan,
 		return skb;
 
 	/* Create L2CAP header */
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->cid = cpu_to_le16(chan->dcid);
 	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 
@@ -2891,7 +2891,7 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn, u8 code,
 	if (!skb)
 		return NULL;
 
-	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
+	lh = skb_put(skb, L2CAP_HDR_SIZE);
 	lh->len = cpu_to_le16(L2CAP_CMD_HDR_SIZE + dlen);
 
 	if (conn->hcon->type == LE_LINK)
@@ -2899,7 +2899,7 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn, u8 code,
 	else
 		lh->cid = cpu_to_le16(L2CAP_CID_SIGNALING);
 
-	cmd = (struct l2cap_cmd_hdr *) skb_put(skb, L2CAP_CMD_HDR_SIZE);
+	cmd = skb_put(skb, L2CAP_CMD_HDR_SIZE);
 	cmd->code  = code;
 	cmd->ident = ident;
 	cmd->len   = cpu_to_le16(dlen);
diff --git a/net/bluetooth/mgmt_util.c b/net/bluetooth/mgmt_util.c
index 8c30c7e..c247fbf 100644
--- a/net/bluetooth/mgmt_util.c
+++ b/net/bluetooth/mgmt_util.c
@@ -37,7 +37,7 @@ int mgmt_send_event(u16 event, struct hci_dev *hdev, unsigned short channel,
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (void *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	hdr->opcode = cpu_to_le16(event);
 	if (hdev)
 		hdr->index = cpu_to_le16(hdev->id);
@@ -70,13 +70,13 @@ int mgmt_cmd_status(struct sock *sk, u16 index, u16 cmd, u8 status)
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (void *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 
 	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_STATUS);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(sizeof(*ev));
 
-	ev = (void *) skb_put(skb, sizeof(*ev));
+	ev = skb_put(skb, sizeof(*ev));
 	ev->status = status;
 	ev->opcode = cpu_to_le16(cmd);
 
@@ -101,13 +101,13 @@ int mgmt_cmd_complete(struct sock *sk, u16 index, u16 cmd, u8 status,
 	if (!skb)
 		return -ENOMEM;
 
-	hdr = (void *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 
 	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_COMPLETE);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(sizeof(*ev) + rp_len);
 
-	ev = (void *) skb_put(skb, sizeof(*ev) + rp_len);
+	ev = skb_put(skb, sizeof(*ev) + rp_len);
 	ev->opcode = cpu_to_le16(cmd);
 	ev->status = status;
 
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 858d848..bf4e51f 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -122,7 +122,7 @@ static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb,
 				   sysctl_ip_default_ttl);
 
 	skb_reset_transport_header(nskb);
-	icmph = (struct icmphdr *)skb_put(nskb, sizeof(struct icmphdr));
+	icmph = skb_put(nskb, sizeof(struct icmphdr));
 	memset(icmph, 0, sizeof(*icmph));
 	icmph->type     = ICMP_DEST_UNREACH;
 	icmph->code	= code;
@@ -234,7 +234,7 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 				     net->ipv6.devconf_all->hop_limit);
 
 	skb_reset_transport_header(nskb);
-	icmp6h = (struct icmp6hdr *)skb_put(nskb, sizeof(struct icmp6hdr));
+	icmp6h = skb_put(nskb, sizeof(struct icmp6hdr));
 	memset(icmp6h, 0, sizeof(*icmp6h));
 	icmp6h->icmp6_type = ICMPV6_DEST_UNREACH;
 	icmp6h->icmp6_code = code;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 508155b..127d466 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2655,7 +2655,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	struct timeval timestamp;
 	struct pktgen_hdr *pgh;
 
-	pgh = (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
+	pgh = skb_put(skb, sizeof(*pgh));
 	datalen -= sizeof(*pgh);
 
 	if (pkt_dev->nfrags <= 0) {
@@ -2784,33 +2784,34 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	/*  Reserve for ethernet and IP header  */
 	eth = (__u8 *) skb_push(skb, 14);
-	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
+	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
 
 	if (pkt_dev->vlan_id != 0xffff) {
 		if (pkt_dev->svlan_id != 0xffff) {
-			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_tci = skb_put(skb, sizeof(__be16));
 			*svlan_tci = build_tci(pkt_dev->svlan_id,
 					       pkt_dev->svlan_cfi,
 					       pkt_dev->svlan_p);
-			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_encapsulated_proto = skb_put(skb,
+							   sizeof(__be16));
 			*svlan_encapsulated_proto = htons(ETH_P_8021Q);
 		}
-		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_tci = skb_put(skb, sizeof(__be16));
 		*vlan_tci = build_tci(pkt_dev->vlan_id,
 				      pkt_dev->vlan_cfi,
 				      pkt_dev->vlan_p);
-		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_encapsulated_proto = skb_put(skb, sizeof(__be16));
 		*vlan_encapsulated_proto = htons(ETH_P_IP);
 	}
 
 	skb_set_mac_header(skb, 0);
 	skb_set_network_header(skb, skb->len);
-	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
+	iph = skb_put(skb, sizeof(struct iphdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+	udph = skb_put(skb, sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
@@ -2911,33 +2912,34 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 	/*  Reserve for ethernet and IP header  */
 	eth = (__u8 *) skb_push(skb, 14);
-	mpls = (__be32 *)skb_put(skb, pkt_dev->nr_labels*sizeof(__u32));
+	mpls = skb_put(skb, pkt_dev->nr_labels * sizeof(__u32));
 	if (pkt_dev->nr_labels)
 		mpls_push(mpls, pkt_dev);
 
 	if (pkt_dev->vlan_id != 0xffff) {
 		if (pkt_dev->svlan_id != 0xffff) {
-			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_tci = skb_put(skb, sizeof(__be16));
 			*svlan_tci = build_tci(pkt_dev->svlan_id,
 					       pkt_dev->svlan_cfi,
 					       pkt_dev->svlan_p);
-			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+			svlan_encapsulated_proto = skb_put(skb,
+							   sizeof(__be16));
 			*svlan_encapsulated_proto = htons(ETH_P_8021Q);
 		}
-		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_tci = skb_put(skb, sizeof(__be16));
 		*vlan_tci = build_tci(pkt_dev->vlan_id,
 				      pkt_dev->vlan_cfi,
 				      pkt_dev->vlan_p);
-		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
+		vlan_encapsulated_proto = skb_put(skb, sizeof(__be16));
 		*vlan_encapsulated_proto = htons(ETH_P_IPV6);
 	}
 
 	skb_set_mac_header(skb, 0);
 	skb_set_network_header(skb, skb->len);
-	iph = (struct ipv6hdr *) skb_put(skb, sizeof(struct ipv6hdr));
+	iph = skb_put(skb, sizeof(struct ipv6hdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+	udph = skb_put(skb, sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index b2c26b0..577d913 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -842,7 +842,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 
 	skb->dev = dev;
 
-	msg = (struct endnode_hello_message *)skb_put(skb,sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 
 	msg->msgflg  = 0x0D;
 	memcpy(msg->tiver, dn_eco_version, 3);
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 62364f7..4a6e961 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -484,7 +484,7 @@ void dn_send_conn_ack (struct sock *sk)
 	if ((skb = dn_alloc_skb(sk, 3, sk->sk_allocation)) == NULL)
 		return;
 
-	msg = (struct nsp_conn_ack_msg *)skb_put(skb, 3);
+	msg = skb_put(skb, 3);
 	msg->msgflg = 0x24;
 	msg->dstaddr = scp->addrrem;
 
@@ -522,7 +522,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	if ((skb = dn_alloc_skb(sk, 50 + len, gfp)) == NULL)
 		return;
 
-	msg = (struct nsp_conn_init_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	msg->msgflg = 0x28;
 	msg->dstaddr = scp->addrrem;
 	msg->srcaddr = scp->addrloc;
@@ -662,7 +662,7 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 		return;
 
 	cb  = DN_SKB_CB(skb);
-	msg = (struct nsp_conn_init_msg *)skb_put(skb,sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 
 	msg->msgflg	= msgflg;
 	msg->dstaddr	= 0x0000;		/* Remote Node will assign it*/
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 933a928..0d82ecf 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -500,7 +500,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
-	arp = (struct arphdr *) skb_put(skb, arp_hdr_len(dev));
+	arp = skb_put(skb, arp_hdr_len(dev));
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_ARP);
 	if (!src_hw)
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a3a697f..d086e11 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -413,7 +413,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ip_mc_list *pmc,
 		skb = igmpv3_newpack(dev, dev->mtu);
 	if (!skb)
 		return NULL;
-	pgr = (struct igmpv3_grec *)skb_put(skb, sizeof(struct igmpv3_grec));
+	pgr = skb_put(skb, sizeof(struct igmpv3_grec));
 	pgr->grec_type = type;
 	pgr->grec_auxwords = 0;
 	pgr->grec_nsrcs = 0;
@@ -495,7 +495,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 		}
 		if (!skb)
 			return NULL;
-		psrc = (__be32 *)skb_put(skb, sizeof(__be32));
+		psrc = skb_put(skb, sizeof(__be32));
 		*psrc = psf->sf_inaddr;
 		scount++; stotal++;
 		if ((type == IGMPV3_ALLOW_NEW_SOURCES ||
@@ -720,7 +720,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	((u8 *)&iph[1])[2] = 0;
 	((u8 *)&iph[1])[3] = 0;
 
-	ih = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
+	ih = skb_put(skb, sizeof(struct igmphdr));
 	ih->type = type;
 	ih->code = 0;
 	ih->csum = 0;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 8e7328c..6583a9c 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -805,7 +805,7 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	if (!skb)
 		return;
 	skb_reserve(skb, hlen);
-	b = (struct bootp_pkt *) skb_put(skb, sizeof(struct bootp_pkt));
+	b = skb_put(skb, sizeof(struct bootp_pkt));
 	memset(b, 0, sizeof(struct bootp_pkt));
 
 	/* Construct IP header */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 3a2c016..e153ec2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1003,7 +1003,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 
 	/* Add our header */
 
-	igmp = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
+	igmp = skb_put(skb, sizeof(struct igmphdr));
 	igmp->type	=
 	msg->im_msgtype = assert;
 	igmp->code	= 0;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index e9e6779..a40070b 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -23,7 +23,7 @@ synproxy_build_ip(struct sk_buff *skb, u32 saddr, u32 daddr)
 	struct iphdr *iph;
 
 	skb_reset_network_header(skb);
-	iph = (struct iphdr *)skb_put(skb, sizeof(*iph));
+	iph = skb_put(skb, sizeof(*iph));
 	iph->version	= 4;
 	iph->ihl	= sizeof(*iph) / 4;
 	iph->tos	= 0;
@@ -89,7 +89,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
 	niph = synproxy_build_ip(nskb, iph->daddr, iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(__cookie_v4_init_sequence(iph, th, &mss));
@@ -130,7 +130,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 	niph = synproxy_build_ip(nskb, iph->saddr, iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(recv_seq - 1);
@@ -175,7 +175,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 	niph = synproxy_build_ip(nskb, iph->daddr, iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(ntohl(th->ack_seq));
@@ -213,7 +213,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	niph = synproxy_build_ip(nskb, iph->saddr, iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(ntohl(th->seq) + 1);
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 3262e41..f6b25b3 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -49,7 +49,7 @@ struct iphdr *nf_reject_iphdr_put(struct sk_buff *nskb,
 	struct iphdr *niph, *oiph = ip_hdr(oldskb);
 
 	skb_reset_network_header(nskb);
-	niph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
+	niph = skb_put(nskb, sizeof(struct iphdr));
 	niph->version	= 4;
 	niph->ihl	= sizeof(struct iphdr) / 4;
 	niph->tos	= 0;
@@ -74,7 +74,7 @@ void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
 	struct tcphdr *tcph;
 
 	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
+	tcph = skb_put(nskb, sizeof(struct tcphdr));
 	memset(tcph, 0, sizeof(*tcph));
 	tcph->source	= oth->dest;
 	tcph->dest	= oth->source;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 083b292..383d0ba 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1680,7 +1680,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 		skb = mld_newpack(pmc->idev, dev->mtu);
 	if (!skb)
 		return NULL;
-	pgr = (struct mld2_grec *)skb_put(skb, sizeof(struct mld2_grec));
+	pgr = skb_put(skb, sizeof(struct mld2_grec));
 	pgr->grec_type = type;
 	pgr->grec_auxwords = 0;
 	pgr->grec_nsrcs = 0;
@@ -1763,7 +1763,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 		}
 		if (!skb)
 			return NULL;
-		psrc = (struct in6_addr *)skb_put(skb, sizeof(*psrc));
+		psrc = skb_put(skb, sizeof(*psrc));
 		*psrc = psf->sf_addr;
 		scount++; stotal++;
 		if ((type == MLD2_ALLOW_NEW_SOURCES ||
@@ -1986,7 +1986,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
-	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct mld_msg));
+	hdr = skb_put(skb, sizeof(struct mld_msg));
 	memset(hdr, 0, sizeof(struct mld_msg));
 	hdr->mld_type = type;
 	hdr->mld_mca = *addr;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 96f153c..ea55198 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -511,7 +511,7 @@ void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	if (!skb)
 		return;
 
-	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	*msg = (struct nd_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
@@ -577,7 +577,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	if (!skb)
 		return;
 
-	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	*msg = (struct nd_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
@@ -629,7 +629,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	if (!skb)
 		return;
 
-	msg = (struct rs_msg *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 	*msg = (struct rs_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_ROUTER_SOLICITATION,
@@ -1543,7 +1543,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	msg = (struct rd_msg *)skb_put(buff, sizeof(*msg));
+	msg = skb_put(buff, sizeof(*msg));
 	*msg = (struct rd_msg) {
 		.icmph = {
 			.icmp6_type = NDISC_REDIRECT,
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 6edb7b1..3a74bdb 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -26,7 +26,7 @@ synproxy_build_ip(struct sk_buff *skb, const struct in6_addr *saddr,
 	struct ipv6hdr *iph;
 
 	skb_reset_network_header(skb);
-	iph = (struct ipv6hdr *)skb_put(skb, sizeof(*iph));
+	iph = skb_put(skb, sizeof(*iph));
 	ip6_flow_hdr(iph, 0, 0);
 	iph->hop_limit	= 64;	//XXX
 	iph->nexthdr	= IPPROTO_TCP;
@@ -104,7 +104,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
 	niph = synproxy_build_ip(nskb, &iph->daddr, &iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(__cookie_v6_init_sequence(iph, th, &mss));
@@ -145,7 +145,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 	niph = synproxy_build_ip(nskb, &iph->saddr, &iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(recv_seq - 1);
@@ -190,7 +190,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 	niph = synproxy_build_ip(nskb, &iph->daddr, &iph->saddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->dest;
 	nth->dest	= th->source;
 	nth->seq	= htonl(ntohl(th->ack_seq));
@@ -228,7 +228,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	niph = synproxy_build_ip(nskb, &iph->saddr, &iph->daddr);
 
 	skb_reset_transport_header(nskb);
-	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
+	nth = skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
 	nth->seq	= htonl(ntohl(th->seq) + 1);
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 94b4c6d..5bcfaf0 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -96,7 +96,7 @@ void nf_reject_ip6_tcphdr_put(struct sk_buff *nskb,
 	int needs_ack;
 
 	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
+	tcph = skb_put(nskb, sizeof(struct tcphdr));
 	/* Truncate to length (no data) */
 	tcph->doff = sizeof(struct tcphdr)/4;
 	tcph->source = oth->dest;
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index b936b12..b6242a2 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -133,7 +133,7 @@ void irlap_send_snrm_frame(struct irlap_cb *self, struct qos_info *qos)
 	if (!tx_skb)
 		return;
 
-	frame = (struct snrm_frame *) skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	/* Insert connection address field */
 	if (qos)
@@ -228,7 +228,7 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
 	if (!tx_skb)
 		return;
 
-	frame = (struct ua_frame *) skb_put(tx_skb, 10);
+	frame = skb_put(tx_skb, 10);
 
 	/* Build UA response */
 	frame->caddr = self->caddr;
@@ -268,7 +268,7 @@ void irlap_send_dm_frame( struct irlap_cb *self)
 	if (!tx_skb)
 		return;
 
-	frame = (struct dm_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	if (self->state == LAP_NDM)
 		frame->caddr = CBROADCAST;
@@ -298,7 +298,7 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 	if (!tx_skb)
 		return;
 
-	frame = (struct disc_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr | CMD_FRAME;
 	frame->control = DISC_CMD | PF_BIT;
@@ -588,7 +588,7 @@ void irlap_send_rr_frame(struct irlap_cb *self, int command)
 	if (!tx_skb)
 		return;
 
-	frame = (struct rr_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr;
 	frame->caddr |= (command) ? CMD_FRAME : 0;
@@ -613,7 +613,7 @@ void irlap_send_rd_frame(struct irlap_cb *self)
 	if (!tx_skb)
 		return;
 
-	frame = (struct rd_frame *)skb_put(tx_skb, 2);
+	frame = skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr;
 	frame->control = RD_RSP | PF_BIT;
@@ -1203,14 +1203,13 @@ void irlap_send_test_frame(struct irlap_cb *self, __u8 caddr, __u32 daddr,
 
 	/* Broadcast frames must include saddr and daddr fields */
 	if (caddr == CBROADCAST) {
-		frame = (struct test_frame *)
-			skb_put(tx_skb, sizeof(struct test_frame));
+		frame = skb_put(tx_skb, sizeof(struct test_frame));
 
 		/* Insert the swapped addresses */
 		frame->saddr = cpu_to_le32(self->saddr);
 		frame->daddr = cpu_to_le32(daddr);
 	} else
-		frame = (struct test_frame *) skb_put(tx_skb, LAP_ADDR_HEADER + LAP_CTRL_HEADER);
+		frame = skb_put(tx_skb, LAP_ADDR_HEADER + LAP_CTRL_HEADER);
 
 	frame->caddr = caddr;
 	frame->control = TEST_RSP | PF_BIT;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f0d52d7..379c44b 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -327,7 +327,7 @@ static int pfkey_error(const struct sadb_msg *orig, int err, struct sock *sk)
 		err = EINVAL;
 	BUG_ON(err <= 0 || err >= 256);
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	pfkey_hdr_dup(hdr, orig);
 	hdr->sadb_msg_errno = (uint8_t) err;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) /
@@ -788,12 +788,12 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		return ERR_PTR(-ENOBUFS);
 
 	/* call should fill header later */
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	memset(hdr, 0, size);	/* XXX do we need this ? */
 	hdr->sadb_msg_len = size / sizeof(uint64_t);
 
 	/* sa */
-	sa = (struct sadb_sa *)  skb_put(skb, sizeof(struct sadb_sa));
+	sa = skb_put(skb, sizeof(struct sadb_sa));
 	sa->sadb_sa_len = sizeof(struct sadb_sa)/sizeof(uint64_t);
 	sa->sadb_sa_exttype = SADB_EXT_SA;
 	sa->sadb_sa_spi = x->id.spi;
@@ -840,8 +840,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	/* hard time */
 	if (hsc & 2) {
-		lifetime = (struct sadb_lifetime *)  skb_put(skb,
-							     sizeof(struct sadb_lifetime));
+		lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 		lifetime->sadb_lifetime_len =
 			sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 		lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_HARD;
@@ -852,8 +851,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 	/* soft time */
 	if (hsc & 1) {
-		lifetime = (struct sadb_lifetime *)  skb_put(skb,
-							     sizeof(struct sadb_lifetime));
+		lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 		lifetime->sadb_lifetime_len =
 			sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 		lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_SOFT;
@@ -863,8 +861,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		lifetime->sadb_lifetime_usetime = x->lft.soft_use_expires_seconds;
 	}
 	/* current time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_CURRENT;
@@ -873,8 +870,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	lifetime->sadb_lifetime_addtime = x->curlft.add_time;
 	lifetime->sadb_lifetime_usetime = x->curlft.use_time;
 	/* src address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -893,8 +889,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		BUG();
 
 	/* dst address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -911,8 +906,8 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	if (!xfrm_addr_equal(&x->sel.saddr, &x->props.saddr,
 			     x->props.family)) {
-		addr = (struct sadb_address*) skb_put(skb,
-			sizeof(struct sadb_address)+sockaddr_size);
+		addr = skb_put(skb,
+			       sizeof(struct sadb_address) + sockaddr_size);
 		addr->sadb_address_len =
 			(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -929,8 +924,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	/* auth key */
 	if (add_keys && auth_key_size) {
-		key = (struct sadb_key *) skb_put(skb,
-						  sizeof(struct sadb_key)+auth_key_size);
+		key = skb_put(skb, sizeof(struct sadb_key) + auth_key_size);
 		key->sadb_key_len = (sizeof(struct sadb_key) + auth_key_size) /
 			sizeof(uint64_t);
 		key->sadb_key_exttype = SADB_EXT_KEY_AUTH;
@@ -940,8 +934,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 	/* encrypt key */
 	if (add_keys && encrypt_key_size) {
-		key = (struct sadb_key *) skb_put(skb,
-						  sizeof(struct sadb_key)+encrypt_key_size);
+		key = skb_put(skb, sizeof(struct sadb_key) + encrypt_key_size);
 		key->sadb_key_len = (sizeof(struct sadb_key) +
 				     encrypt_key_size) / sizeof(uint64_t);
 		key->sadb_key_exttype = SADB_EXT_KEY_ENCRYPT;
@@ -952,7 +945,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 
 	/* sa */
-	sa2 = (struct sadb_x_sa2 *)  skb_put(skb, sizeof(struct sadb_x_sa2));
+	sa2 = skb_put(skb, sizeof(struct sadb_x_sa2));
 	sa2->sadb_x_sa2_len = sizeof(struct sadb_x_sa2)/sizeof(uint64_t);
 	sa2->sadb_x_sa2_exttype = SADB_X_EXT_SA2;
 	if ((mode = pfkey_mode_from_xfrm(x->props.mode)) < 0) {
@@ -970,7 +963,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		struct sadb_x_nat_t_port *n_port;
 
 		/* type */
-		n_type = (struct sadb_x_nat_t_type*) skb_put(skb, sizeof(*n_type));
+		n_type = skb_put(skb, sizeof(*n_type));
 		n_type->sadb_x_nat_t_type_len = sizeof(*n_type)/sizeof(uint64_t);
 		n_type->sadb_x_nat_t_type_exttype = SADB_X_EXT_NAT_T_TYPE;
 		n_type->sadb_x_nat_t_type_type = natt->encap_type;
@@ -979,14 +972,14 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		n_type->sadb_x_nat_t_type_reserved[2] = 0;
 
 		/* source port */
-		n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+		n_port = skb_put(skb, sizeof(*n_port));
 		n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 		n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_SPORT;
 		n_port->sadb_x_nat_t_port_port = natt->encap_sport;
 		n_port->sadb_x_nat_t_port_reserved = 0;
 
 		/* dest port */
-		n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+		n_port = skb_put(skb, sizeof(*n_port));
 		n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 		n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_DPORT;
 		n_port->sadb_x_nat_t_port_port = natt->encap_dport;
@@ -995,8 +988,8 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 
 	/* security context */
 	if (xfrm_ctx) {
-		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb,
-				sizeof(struct sadb_x_sec_ctx) + ctx_size);
+		sec_ctx = skb_put(skb,
+				  sizeof(struct sadb_x_sec_ctx) + ctx_size);
 		sec_ctx->sadb_x_sec_len =
 		  (sizeof(struct sadb_x_sec_ctx) + ctx_size) / sizeof(uint64_t);
 		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
@@ -1594,7 +1587,7 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 	if (!skb)
 		goto out_put_algs;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	pfkey_hdr_dup(hdr, orig);
 	hdr->sadb_msg_errno = 0;
 	hdr->sadb_msg_len = len / sizeof(uint64_t);
@@ -1603,7 +1596,7 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 		struct sadb_supported *sp;
 		struct sadb_alg *ap;
 
-		sp = (struct sadb_supported *) skb_put(skb, auth_len);
+		sp = skb_put(skb, auth_len);
 		ap = (struct sadb_alg *) (sp + 1);
 
 		sp->sadb_supported_len = auth_len / sizeof(uint64_t);
@@ -1624,7 +1617,7 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 		struct sadb_supported *sp;
 		struct sadb_alg *ap;
 
-		sp = (struct sadb_supported *) skb_put(skb, enc_len);
+		sp = skb_put(skb, enc_len);
 		ap = (struct sadb_alg *) (sp + 1);
 
 		sp->sadb_supported_len = enc_len / sizeof(uint64_t);
@@ -1683,7 +1676,7 @@ static int unicast_flush_resp(struct sock *sk, const struct sadb_msg *ihdr)
 	if (!skb)
 		return -ENOBUFS;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	memcpy(hdr, ihdr, sizeof(struct sadb_msg));
 	hdr->sadb_msg_errno = (uint8_t) 0;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
@@ -1699,7 +1692,7 @@ static int key_notify_sa_flush(const struct km_event *c)
 	skb = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
 	if (!skb)
 		return -ENOBUFS;
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_satype = pfkey_proto2satype(c->data.proto);
 	hdr->sadb_msg_type = SADB_FLUSH;
 	hdr->sadb_msg_seq = c->seq;
@@ -2017,12 +2010,11 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	size = pfkey_xfrm_policy2msg_size(xp);
 
 	/* call should fill header later */
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	memset(hdr, 0, size);	/* XXX do we need this ? */
 
 	/* src address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -2037,8 +2029,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 		BUG();
 
 	/* dst address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -2052,8 +2043,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 			    xp->family);
 
 	/* hard time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_HARD;
@@ -2062,8 +2052,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	lifetime->sadb_lifetime_addtime = xp->lft.hard_add_expires_seconds;
 	lifetime->sadb_lifetime_usetime = xp->lft.hard_use_expires_seconds;
 	/* soft time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_SOFT;
@@ -2072,8 +2061,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	lifetime->sadb_lifetime_addtime = xp->lft.soft_add_expires_seconds;
 	lifetime->sadb_lifetime_usetime = xp->lft.soft_use_expires_seconds;
 	/* current time */
-	lifetime = (struct sadb_lifetime *)  skb_put(skb,
-						     sizeof(struct sadb_lifetime));
+	lifetime = skb_put(skb, sizeof(struct sadb_lifetime));
 	lifetime->sadb_lifetime_len =
 		sizeof(struct sadb_lifetime)/sizeof(uint64_t);
 	lifetime->sadb_lifetime_exttype = SADB_EXT_LIFETIME_CURRENT;
@@ -2082,7 +2070,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	lifetime->sadb_lifetime_addtime = xp->curlft.add_time;
 	lifetime->sadb_lifetime_usetime = xp->curlft.use_time;
 
-	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
+	pol = skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = sizeof(struct sadb_x_policy)/sizeof(uint64_t);
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_DISCARD;
@@ -2110,7 +2098,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 		} else {
 			size -= 2*socklen;
 		}
-		rq = (void*)skb_put(skb, req_size);
+		rq = skb_put(skb, req_size);
 		pol->sadb_x_policy_len += req_size/8;
 		memset(rq, 0, sizeof(*rq));
 		rq->sadb_x_ipsecrequest_len = req_size;
@@ -2140,7 +2128,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	if ((xfrm_ctx = xp->security)) {
 		int ctx_size = pfkey_xfrm_policy2sec_ctx_size(xp);
 
-		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb, ctx_size);
+		sec_ctx = skb_put(skb, ctx_size);
 		sec_ctx->sadb_x_sec_len = ctx_size / sizeof(uint64_t);
 		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
 		sec_ctx->sadb_x_ctx_doi = xfrm_ctx->ctx_doi;
@@ -2698,7 +2686,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
 	if (!skb_out)
 		return -ENOBUFS;
-	hdr = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
+	hdr = skb_put(skb_out, sizeof(struct sadb_msg));
 	hdr->sadb_msg_type = SADB_X_SPDFLUSH;
 	hdr->sadb_msg_seq = c->seq;
 	hdr->sadb_msg_pid = c->portid;
@@ -2882,7 +2870,7 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 	struct sadb_prop *p;
 	int i;
 
-	p = (struct sadb_prop*)skb_put(skb, sizeof(struct sadb_prop));
+	p = skb_put(skb, sizeof(struct sadb_prop));
 	p->sadb_prop_len = sizeof(struct sadb_prop)/8;
 	p->sadb_prop_exttype = SADB_EXT_PROPOSAL;
 	p->sadb_prop_replay = 32;
@@ -2898,7 +2886,7 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 
 		if (aalg_tmpl_set(t, aalg) && aalg->available) {
 			struct sadb_comb *c;
-			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
+			c = skb_put(skb, sizeof(struct sadb_comb));
 			memset(c, 0, sizeof(*c));
 			p->sadb_prop_len += sizeof(struct sadb_comb)/8;
 			c->sadb_comb_auth = aalg->desc.sadb_alg_id;
@@ -2917,7 +2905,7 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 	struct sadb_prop *p;
 	int i, k;
 
-	p = (struct sadb_prop*)skb_put(skb, sizeof(struct sadb_prop));
+	p = skb_put(skb, sizeof(struct sadb_prop));
 	p->sadb_prop_len = sizeof(struct sadb_prop)/8;
 	p->sadb_prop_exttype = SADB_EXT_PROPOSAL;
 	p->sadb_prop_replay = 32;
@@ -2943,7 +2931,7 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 				continue;
 			if (!(aalg_tmpl_set(t, aalg) && aalg->available))
 				continue;
-			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
+			c = skb_put(skb, sizeof(struct sadb_comb));
 			memset(c, 0, sizeof(*c));
 			p->sadb_prop_len += sizeof(struct sadb_comb)/8;
 			c->sadb_comb_auth = aalg->desc.sadb_alg_id;
@@ -3110,7 +3098,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	if (skb == NULL)
 		return -ENOMEM;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_type = SADB_ACQUIRE;
 	hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
@@ -3121,8 +3109,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	hdr->sadb_msg_pid = 0;
 
 	/* src address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3137,8 +3124,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 		BUG();
 
 	/* dst address */
-	addr = (struct sadb_address*) skb_put(skb,
-					      sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3152,7 +3138,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	if (!addr->sadb_address_prefixlen)
 		BUG();
 
-	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
+	pol = skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = sizeof(struct sadb_x_policy)/sizeof(uint64_t);
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
@@ -3169,8 +3155,8 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 
 	/* security context */
 	if (xfrm_ctx) {
-		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb,
-				sizeof(struct sadb_x_sec_ctx) + ctx_size);
+		sec_ctx = skb_put(skb,
+				  sizeof(struct sadb_x_sec_ctx) + ctx_size);
 		sec_ctx->sadb_x_sec_len =
 		  (sizeof(struct sadb_x_sec_ctx) + ctx_size) / sizeof(uint64_t);
 		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
@@ -3312,7 +3298,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_type = SADB_X_NAT_T_NEW_MAPPING;
 	hdr->sadb_msg_satype = satype;
@@ -3323,7 +3309,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	hdr->sadb_msg_pid = 0;
 
 	/* SA */
-	sa = (struct sadb_sa *) skb_put(skb, sizeof(struct sadb_sa));
+	sa = skb_put(skb, sizeof(struct sadb_sa));
 	sa->sadb_sa_len = sizeof(struct sadb_sa)/sizeof(uint64_t);
 	sa->sadb_sa_exttype = SADB_EXT_SA;
 	sa->sadb_sa_spi = x->id.spi;
@@ -3334,8 +3320,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	sa->sadb_sa_flags = 0;
 
 	/* ADDRESS_SRC (old addr) */
-	addr = (struct sadb_address*)
-		skb_put(skb, sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3350,15 +3335,14 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 		BUG();
 
 	/* NAT_T_SPORT (old port) */
-	n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+	n_port = skb_put(skb, sizeof(*n_port));
 	n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 	n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_SPORT;
 	n_port->sadb_x_nat_t_port_port = natt->encap_sport;
 	n_port->sadb_x_nat_t_port_reserved = 0;
 
 	/* ADDRESS_DST (new addr) */
-	addr = (struct sadb_address*)
-		skb_put(skb, sizeof(struct sadb_address)+sockaddr_size);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sockaddr_size);
 	addr->sadb_address_len =
 		(sizeof(struct sadb_address)+sockaddr_size)/
 			sizeof(uint64_t);
@@ -3373,7 +3357,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 		BUG();
 
 	/* NAT_T_DPORT (new port) */
-	n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
+	n_port = skb_put(skb, sizeof(*n_port));
 	n_port->sadb_x_nat_t_port_len = sizeof(*n_port)/sizeof(uint64_t);
 	n_port->sadb_x_nat_t_port_exttype = SADB_X_EXT_NAT_T_DPORT;
 	n_port->sadb_x_nat_t_port_port = sport;
@@ -3387,7 +3371,7 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 			    const struct xfrm_selector *sel)
 {
 	struct sadb_address *addr;
-	addr = (struct sadb_address *)skb_put(skb, sizeof(struct sadb_address) + sasize);
+	addr = skb_put(skb, sizeof(struct sadb_address) + sasize);
 	addr->sadb_address_len = (sizeof(struct sadb_address) + sasize)/8;
 	addr->sadb_address_exttype = type;
 	addr->sadb_address_proto = sel->proto;
@@ -3425,7 +3409,7 @@ static int set_sadb_kmaddress(struct sk_buff *skb, const struct xfrm_kmaddress *
 	size_req = (sizeof(struct sadb_x_kmaddress) +
 		    pfkey_sockaddr_pair_size(family));
 
-	kma = (struct sadb_x_kmaddress *)skb_put(skb, size_req);
+	kma = skb_put(skb, size_req);
 	memset(kma, 0, size_req);
 	kma->sadb_x_kmaddress_len = size_req / 8;
 	kma->sadb_x_kmaddress_exttype = SADB_X_EXT_KMADDRESS;
@@ -3452,7 +3436,7 @@ static int set_ipsecrequest(struct sk_buff *skb,
 	size_req = sizeof(struct sadb_x_ipsecrequest) +
 		   pfkey_sockaddr_pair_size(family);
 
-	rq = (struct sadb_x_ipsecrequest *)skb_put(skb, size_req);
+	rq = skb_put(skb, size_req);
 	memset(rq, 0, size_req);
 	rq->sadb_x_ipsecrequest_len = size_req;
 	rq->sadb_x_ipsecrequest_proto = proto;
@@ -3521,7 +3505,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	hdr = (struct sadb_msg *)skb_put(skb, sizeof(struct sadb_msg));
+	hdr = skb_put(skb, sizeof(struct sadb_msg));
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_type = SADB_X_MIGRATE;
 	hdr->sadb_msg_satype = pfkey_proto2satype(m->proto);
@@ -3542,7 +3526,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	set_sadb_address(skb, sasize_sel, SADB_EXT_ADDRESS_DST, sel);
 
 	/* policy information */
-	pol = (struct sadb_x_policy *)skb_put(skb, sizeof(struct sadb_x_policy));
+	pol = skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = size_pol / 8;
 	pol->sadb_x_policy_exttype = SADB_X_EXT_POLICY;
 	pol->sadb_x_policy_type = IPSEC_POLICY_IPSEC;
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 5c564a6..b7c4fab 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -196,7 +196,7 @@ static void ieee80211_send_addba_resp(struct ieee80211_sub_if_data *sdata, u8 *d
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	mgmt = skb_put(skb, 24);
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, da, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index cce9d42..f283152 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -75,7 +75,7 @@ static void ieee80211_send_addba_request(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	mgmt = skb_put(skb, 24);
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, da, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
@@ -123,7 +123,7 @@ void ieee80211_send_bar(struct ieee80211_vif *vif, u8 *ra, u16 tid, u16 ssn)
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	bar = (struct ieee80211_bar *)skb_put(skb, sizeof(*bar));
+	bar = skb_put(skb, sizeof(*bar));
 	memset(bar, 0, sizeof(*bar));
 	bar->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					 IEEE80211_STYPE_BACK_REQ);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 265e427..21eebdd 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -939,7 +939,7 @@ static void ieee80211_send_layer2_update(struct sta_info *sta)
 	skb = dev_alloc_skb(sizeof(*msg));
 	if (!skb)
 		return;
-	msg = (struct iapp_layer2_update *)skb_put(skb, sizeof(*msg));
+	msg = skb_put(skb, sizeof(*msg));
 
 	/* 802.2 Type 1 Logical Link Control (LLC) Exchange Identifier (XID)
 	 * Update response frame; IEEE Std 802.2-1998, 5.4.1.2.1 */
@@ -3558,7 +3558,7 @@ static int ieee80211_probe_client(struct wiphy *wiphy, struct net_device *dev,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (void *) skb_put(skb, size);
+	nullfunc = skb_put(skb, size);
 	nullfunc->frame_control = fc;
 	nullfunc->duration_id = 0;
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 29236e8..be7ea51 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -308,7 +308,7 @@ static ssize_t ieee80211_if_parse_tkip_mic_test(
 		return -ENOMEM;
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	hdr = (struct ieee80211_hdr *) skb_put(skb, 24);
+	hdr = skb_put(skb, 24);
 	memset(hdr, 0, 24);
 	fc = cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA);
 
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 7a76ce6..9965f52 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -369,7 +369,7 @@ void ieee80211_send_delba(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	mgmt = skb_put(skb, 24);
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, da, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
@@ -435,7 +435,7 @@ int ieee80211_send_smps_action(struct ieee80211_sub_if_data *sdata,
 		return -ENOMEM;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	action_frame = (void *)skb_put(skb, 27);
+	action_frame = skb_put(skb, 27);
 	memcpy(action_frame->da, da, ETH_ALEN);
 	memcpy(action_frame->sa, sdata->dev->dev_addr, ETH_ALEN);
 	memcpy(action_frame->bssid, bssid, ETH_ALEN);
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index d468424..819b2d3 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -653,7 +653,7 @@ ieee80211_mesh_build_beacon(struct ieee80211_if_mesh *ifmsh)
 	bcn->head = ((u8 *) bcn) + sizeof(*bcn);
 
 	/* fill in the head */
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
+	mgmt = skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_BEACON);
@@ -1120,7 +1120,7 @@ static int mesh_fwd_csa_frame(struct ieee80211_sub_if_data *sdata,
 	if (!skb)
 		return -ENOMEM;
 	skb_reserve(skb, local->tx_headroom);
-	mgmt_fwd = (struct ieee80211_mgmt *) skb_put(skb, len);
+	mgmt_fwd = skb_put(skb, len);
 
 	/* offset_ttl is based on whether the secondary channel
 	 * offset is available or not. Subtract 1 from the mesh TTL
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 214e63b..a252057 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -122,7 +122,7 @@ static int mesh_path_sel_frame_tx(enum mpath_frame_type action, u8 flags,
 	if (!skb)
 		return -1;
 	skb_reserve(skb, local->tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
+	mgmt = skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
@@ -259,7 +259,7 @@ int mesh_path_error_tx(struct ieee80211_sub_if_data *sdata,
 	if (!skb)
 		return -1;
 	skb_reserve(skb, local->tx_headroom + sdata->encrypt_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
+	mgmt = skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 60d737f..a1393a8 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -286,7 +286,7 @@ static int mesh_plink_frame_tx(struct ieee80211_sub_if_data *sdata,
 		return err;
 	info = IEEE80211_SKB_CB(skb);
 	skb_reserve(skb, local->tx_headroom);
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
+	mgmt = skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
diff --git a/net/mac80211/mesh_ps.c b/net/mac80211/mesh_ps.c
index ad8b377..783ac59 100644
--- a/net/mac80211/mesh_ps.c
+++ b/net/mac80211/mesh_ps.c
@@ -30,7 +30,7 @@ static struct sk_buff *mps_qos_null_get(struct sta_info *sta)
 		return NULL;
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (struct ieee80211_hdr *) skb_put(skb, size);
+	nullfunc = skb_put(skb, size);
 	fc = cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_QOS_NULLFUNC);
 	ieee80211_fill_mesh_addresses(nullfunc, &fc, sta->sta.addr,
 				      sdata->vif.addr);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 26053bf..cdfc91ca 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -685,7 +685,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 	if (ifmgd->flags & IEEE80211_STA_ENABLE_RRM)
 		capab |= WLAN_CAPABILITY_RADIO_MEASURE;
 
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	mgmt = skb_put(skb, 24);
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, assoc_data->bss->bssid, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
@@ -954,7 +954,7 @@ static void ieee80211_send_4addr_nullfunc(struct ieee80211_local *local,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (struct ieee80211_hdr *) skb_put(skb, 30);
+	nullfunc = skb_put(skb, 30);
 	memset(nullfunc, 0, 30);
 	fc = cpu_to_le16(IEEE80211_FTYPE_DATA | IEEE80211_STYPE_NULLFUNC |
 			 IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 260eed4..b1aaea6 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2512,7 +2512,7 @@ static void ieee80211_process_sa_query_req(struct ieee80211_sub_if_data *sdata,
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	resp = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	resp = skb_put(skb, 24);
 	memset(resp, 0, 24);
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
 	memcpy(resp->sa, sdata->vif.addr, ETH_ALEN);
diff --git a/net/mac80211/spectmgmt.c b/net/mac80211/spectmgmt.c
index 06e6ac8..8c82709 100644
--- a/net/mac80211/spectmgmt.c
+++ b/net/mac80211/spectmgmt.c
@@ -197,7 +197,7 @@ static void ieee80211_send_refuse_measurement_request(struct ieee80211_sub_if_da
 		return;
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
-	msr_report = (struct ieee80211_mgmt *)skb_put(skb, 24);
+	msr_report = skb_put(skb, 24);
 	memset(msr_report, 0, 24);
 	memcpy(msr_report->da, da, ETH_ALEN);
 	memcpy(msr_report->sa, sdata->vif.addr, ETH_ALEN);
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 12971b7..888632b 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1233,7 +1233,7 @@ static void ieee80211_send_null_response(struct ieee80211_sub_if_data *sdata,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (void *) skb_put(skb, size);
+	nullfunc = skb_put(skb, size);
 	nullfunc->frame_control = fc;
 	nullfunc->duration_id = 0;
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
diff --git a/net/mac80211/tdls.c b/net/mac80211/tdls.c
index fff0d86..58f4832 100644
--- a/net/mac80211/tdls.c
+++ b/net/mac80211/tdls.c
@@ -38,7 +38,7 @@ void ieee80211_tdls_peer_del_work(struct work_struct *wk)
 static void ieee80211_tdls_add_ext_capab(struct ieee80211_local *local,
 					 struct sk_buff *skb)
 {
-	u8 *pos = (void *)skb_put(skb, 7);
+	u8 *pos = skb_put(skb, 7);
 	bool chan_switch = local->hw.wiphy->features &
 			   NL80211_FEATURE_TDLS_CHANNEL_SWITCH;
 
@@ -156,7 +156,7 @@ static void ieee80211_tdls_add_oper_classes(struct ieee80211_sub_if_data *sdata,
 
 static void ieee80211_tdls_add_bss_coex_ie(struct sk_buff *skb)
 {
-	u8 *pos = (void *)skb_put(skb, 3);
+	u8 *pos = skb_put(skb, 3);
 
 	*pos++ = WLAN_EID_BSS_COEX_2040;
 	*pos++ = 1; /* len */
@@ -201,7 +201,7 @@ static void ieee80211_tdls_add_link_ie(struct ieee80211_sub_if_data *sdata,
 		rsp_addr = sdata->vif.addr;
 	}
 
-	lnkid = (void *)skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
+	lnkid = skb_put(skb, sizeof(struct ieee80211_tdls_lnkie));
 
 	lnkid->ie_type = WLAN_EID_LINK_ID;
 	lnkid->ie_len = sizeof(struct ieee80211_tdls_lnkie) - 2;
@@ -215,7 +215,7 @@ static void
 ieee80211_tdls_add_aid(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 {
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
-	u8 *pos = (void *)skb_put(skb, 4);
+	u8 *pos = skb_put(skb, 4);
 
 	*pos++ = WLAN_EID_AID;
 	*pos++ = 2; /* len */
@@ -263,7 +263,7 @@ static void ieee80211_tdls_add_wmm_param_ie(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_tx_queue_params *txq;
 	int i;
 
-	wmm = (void *)skb_put(skb, sizeof(*wmm));
+	wmm = skb_put(skb, sizeof(*wmm));
 	memset(wmm, 0, sizeof(*wmm));
 
 	wmm->element_id = WLAN_EID_VENDOR_SPECIFIC;
@@ -675,7 +675,7 @@ ieee80211_prep_tdls_encap_data(struct wiphy *wiphy, struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_tdls_data *tf;
 
-	tf = (void *)skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
+	tf = skb_put(skb, offsetof(struct ieee80211_tdls_data, u));
 
 	memcpy(tf->da, peer, ETH_ALEN);
 	memcpy(tf->sa, sdata->vif.addr, ETH_ALEN);
@@ -757,7 +757,7 @@ ieee80211_prep_tdls_direct(struct wiphy *wiphy, struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_mgmt *mgmt;
 
-	mgmt = (void *)skb_put(skb, 24);
+	mgmt = skb_put(skb, 24);
 	memset(mgmt, 0, 24);
 	memcpy(mgmt->da, peer, ETH_ALEN);
 	memcpy(mgmt->sa, sdata->vif.addr, ETH_ALEN);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 667111e..22f3382 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2599,7 +2599,7 @@ static void __ieee80211_beacon_add_tim(struct ieee80211_sub_if_data *sdata,
 			ps->dtim_count--;
 	}
 
-	tim = pos = (u8 *) skb_put(skb, 6);
+	tim = pos = skb_put(skb, 6);
 	*pos++ = WLAN_EID_TIM;
 	*pos++ = 4;
 	*pos++ = ps->dtim_count;
@@ -3071,7 +3071,7 @@ struct sk_buff *ieee80211_pspoll_get(struct ieee80211_hw *hw,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	pspoll = (struct ieee80211_pspoll *) skb_put(skb, sizeof(*pspoll));
+	pspoll = skb_put(skb, sizeof(*pspoll));
 	memset(pspoll, 0, sizeof(*pspoll));
 	pspoll->frame_control = cpu_to_le16(IEEE80211_FTYPE_CTL |
 					    IEEE80211_STYPE_PSPOLL);
@@ -3109,8 +3109,7 @@ struct sk_buff *ieee80211_nullfunc_get(struct ieee80211_hw *hw,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	nullfunc = (struct ieee80211_hdr_3addr *) skb_put(skb,
-							  sizeof(*nullfunc));
+	nullfunc = skb_put(skb, sizeof(*nullfunc));
 	memset(nullfunc, 0, sizeof(*nullfunc));
 	nullfunc->frame_control = cpu_to_le16(IEEE80211_FTYPE_DATA |
 					      IEEE80211_STYPE_NULLFUNC |
@@ -3143,7 +3142,7 @@ struct sk_buff *ieee80211_probereq_get(struct ieee80211_hw *hw,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom);
 
-	hdr = (struct ieee80211_hdr_3addr *) skb_put(skb, sizeof(*hdr));
+	hdr = skb_put(skb, sizeof(*hdr));
 	memset(hdr, 0, sizeof(*hdr));
 	hdr->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					 IEEE80211_STYPE_PROBE_REQ);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 79412f1..54c053f 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1282,7 +1282,7 @@ void ieee80211_send_auth(struct ieee80211_sub_if_data *sdata,
 
 	skb_reserve(skb, local->hw.extra_tx_headroom + IEEE80211_WEP_IV_LEN);
 
-	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
+	mgmt = skb_put(skb, 24 + 6);
 	memset(mgmt, 0, 24 + 6);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_AUTH);
@@ -2847,7 +2847,7 @@ int ieee80211_send_action_csa(struct ieee80211_sub_if_data *sdata,
 		return -ENOMEM;
 
 	skb_reserve(skb, local->tx_headroom);
-	mgmt = (struct ieee80211_mgmt *)skb_put(skb, hdr_len);
+	mgmt = skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT |
 					  IEEE80211_STYPE_ACTION);
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 9d63d93..4cf6844 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -934,7 +934,7 @@ ieee80211_crypto_aes_cmac_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
-	mmie = (struct ieee80211_mmie *) skb_put(skb, sizeof(*mmie));
+	mmie = skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
 	mmie->key_id = cpu_to_le16(key->conf.keyidx);
@@ -978,7 +978,7 @@ ieee80211_crypto_aes_cmac_256_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
-	mmie = (struct ieee80211_mmie_16 *)skb_put(skb, sizeof(*mmie));
+	mmie = skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
 	mmie->key_id = cpu_to_le16(key->conf.keyidx);
@@ -1123,7 +1123,7 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
-	mmie = (struct ieee80211_mmie_16 *)skb_put(skb, sizeof(*mmie));
+	mmie = skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
 	mmie->key_id = cpu_to_le16(key->conf.keyidx);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3ad9126..e6476fe 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -582,7 +582,7 @@ __build_packet_message(struct nfnl_log_net *log,
 		if (skb_tailroom(inst->skb) < nla_total_size(data_len))
 			goto nla_put_failure;
 
-		nla = (struct nlattr *)skb_put(inst->skb, nla_total_size(data_len));
+		nla = skb_put(inst->skb, nla_total_size(data_len));
 		nla->nla_type = NFULA_PAYLOAD;
 		nla->nla_len = size;
 
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 0b98c74..5639ca1 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -495,7 +495,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		if (skb_tailroom(skb) < sizeof(*nla) + hlen)
 			goto nla_put_failure;
 
-		nla = (struct nlattr *)skb_put(skb, sizeof(*nla));
+		nla = skb_put(skb, sizeof(*nla));
 		nla->nla_type = NFQA_PAYLOAD;
 		nla->nla_len = nla_attr_size(data_len);
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..5d74442 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2604,7 +2604,7 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 	struct nlmsghdr *nlh;
 	int size = nlmsg_msg_size(len);
 
-	nlh = (struct nlmsghdr *)skb_put(skb, NLMSG_ALIGN(size));
+	nlh = skb_put(skb, NLMSG_ALIGN(size));
 	nlh->nlmsg_type = type;
 	nlh->nlmsg_len = size;
 	nlh->nlmsg_flags = flags;
diff --git a/net/nfc/digital_technology.c b/net/nfc/digital_technology.c
index dbae4b8..a623b23 100644
--- a/net/nfc/digital_technology.c
+++ b/net/nfc/digital_technology.c
@@ -625,8 +625,7 @@ static int digital_in_send_attrib_req(struct nfc_digital_dev *ddev,
 	if (!skb)
 		return -ENOMEM;
 
-	attrib_req = (struct digital_attrib_req *)skb_put(skb,
-							  sizeof(*attrib_req));
+	attrib_req = skb_put(skb, sizeof(*attrib_req));
 
 	attrib_req->cmd = DIGITAL_CMD_ATTRIB_REQ;
 	memcpy(attrib_req->nfcid0, sensb_res->nfcid0,
@@ -730,8 +729,7 @@ int digital_in_send_sensb_req(struct nfc_digital_dev *ddev, u8 rf_tech)
 	if (!skb)
 		return -ENOMEM;
 
-	sensb_req = (struct digital_sensb_req *)skb_put(skb,
-							sizeof(*sensb_req));
+	sensb_req = skb_put(skb, sizeof(*sensb_req));
 
 	sensb_req->cmd = DIGITAL_CMD_SENSB_REQ;
 	sensb_req->afi = 0x00; /* All families and sub-families */
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 49ff321..218be62 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1148,7 +1148,7 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 		return -ENOMEM;
 	}
 
-	hdr = (struct nci_ctrl_hdr *) skb_put(skb, NCI_CTRL_HDR_SIZE);
+	hdr = skb_put(skb, NCI_CTRL_HDR_SIZE);
 	hdr->gid = nci_opcode_gid(opcode);
 	hdr->oid = nci_opcode_oid(opcode);
 	hdr->plen = plen;
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 5e71043..6901f5b 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -108,7 +108,7 @@ static int pn_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		return err;
 	skb_reserve(skb, MAX_PHONET_HEADER);
 
-	err = memcpy_from_msg((void *)skb_put(skb, len), msg, len);
+	err = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 06320c8..2fa57e0 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1375,7 +1375,7 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 		goto nodata;
 
 	/* Make room for the chunk header.  */
-	chunk_hdr = (sctp_chunkhdr_t *)skb_put(skb, sizeof(sctp_chunkhdr_t));
+	chunk_hdr = skb_put(skb, sizeof(sctp_chunkhdr_t));
 	chunk_hdr->type	  = type;
 	chunk_hdr->flags  = flags;
 	chunk_hdr->length = htons(sizeof(sctp_chunkhdr_t));
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index d1e3830..2202755 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -164,8 +164,7 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 			goto fail;
 
 		skb = sctp_event2skb(event);
-		sac = (struct sctp_assoc_change *) skb_put(skb,
-					sizeof(struct sctp_assoc_change));
+		sac = skb_put(skb, sizeof(struct sctp_assoc_change));
 	}
 
 	/* Socket Extensions for SCTP
@@ -267,8 +266,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_peer_addr_change(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	spc = (struct sctp_paddr_change *)
-		skb_put(skb, sizeof(struct sctp_paddr_change));
+	spc = skb_put(skb, sizeof(struct sctp_paddr_change));
 
 	/* Sockets API Extensions for SCTP
 	 * Section 5.3.1.2 SCTP_PEER_ADDR_CHANGE
@@ -546,8 +544,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_shutdown_event(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	sse = (struct sctp_shutdown_event *)
-		skb_put(skb, sizeof(struct sctp_shutdown_event));
+	sse = skb_put(skb, sizeof(struct sctp_shutdown_event));
 
 	/* Socket Extensions for SCTP
 	 * 5.3.1.5 SCTP_SHUTDOWN_EVENT
@@ -609,8 +606,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_adaptation_indication(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	sai = (struct sctp_adaptation_event *)
-		skb_put(skb, sizeof(struct sctp_adaptation_event));
+	sai = skb_put(skb, sizeof(struct sctp_adaptation_event));
 
 	sai->sai_type = SCTP_ADAPTATION_INDICATION;
 	sai->sai_flags = 0;
@@ -742,8 +738,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_pdapi(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	pd = (struct sctp_pdapi_event *)
-		skb_put(skb, sizeof(struct sctp_pdapi_event));
+	pd = skb_put(skb, sizeof(struct sctp_pdapi_event));
 
 	/* pdapi_type
 	 *   It should be SCTP_PARTIAL_DELIVERY_EVENT
@@ -794,8 +789,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_authkey(
 		goto fail;
 
 	skb = sctp_event2skb(event);
-	ak = (struct sctp_authkey_event *)
-		skb_put(skb, sizeof(struct sctp_authkey_event));
+	ak = skb_put(skb, sizeof(struct sctp_authkey_event));
 
 	ak->auth_type = SCTP_AUTHENTICATION_EVENT;
 	ak->auth_flags = 0;
@@ -833,8 +827,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 		return NULL;
 
 	skb = sctp_event2skb(event);
-	sdry = (struct sctp_sender_dry_event *)
-		skb_put(skb, sizeof(struct sctp_sender_dry_event));
+	sdry = skb_put(skb, sizeof(struct sctp_sender_dry_event));
 
 	sdry->sender_dry_type = SCTP_SENDER_DRY_EVENT;
 	sdry->sender_dry_flags = 0;
-- 
2.1.4
