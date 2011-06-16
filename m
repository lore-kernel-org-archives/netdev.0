From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Thu, 16 Jun 2011 10:23:49 -0500
Message-ID: <BANLkTik0YOAtfyjoed61rMzanij+acEO4A@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com>
	<486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat.org>,
	David Dillow <dave@thed
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58134 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542Ab1FPPXw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 11:23:52 -0400
In-Reply-To: <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2011 at 11:02 PM, Joe Perches <joe@perches.com> wrote:
> Unnecessary casts of void * clutter the code.
>
> These are the remainder casts after several specific
> patches to remove netdev_priv and dev_priv.
>
> Done via coccinelle script:
>
> $ cat cast_void_pointer.cocci
> @@
> type T;
> T *pt;
> void *pv;
> @@
>
> - pt =3D (T *)pv;
> + pt =3D pv;
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> =A0drivers/net/a2065.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/appletalk/ltpc.c =A0 =A0 =A0 =A0| =A0 =A08 +++---
> =A0drivers/net/atl1e/atl1e_main.c =A0 =A0 =A0| =A0 =A05 +--
> =A0drivers/net/atlx/atl2.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0drivers/net/benet/be_cmds.c =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0drivers/net/benet/be_ethtool.c =A0 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/bna/bfa_cee.c =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/bna/cna.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/caif/caif_shmcore.c =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/cnic.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +=
-
> =A0drivers/net/cxgb3/cxgb3_offload.c =A0 | =A0 =A02 +-
> =A0drivers/net/davinci_cpdma.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/declance.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 38 +++++++=
++++++++++------------
> =A0drivers/net/depca.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +-
> =A0drivers/net/dl2k.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +=
-
> =A0drivers/net/ehea/ehea_qmr.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/epic100.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +-
> =A0drivers/net/fealnx.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/gianfar.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +-
> =A0drivers/net/hamachi.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +-
> =A0drivers/net/macmace.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/mlx4/en_rx.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/mlx4/en_tx.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 +--
> =A0drivers/net/myri_sbus.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0drivers/net/netxen/netxen_nic_ctx.c | =A0 16 ++++++------
> =A0drivers/net/pxa168_eth.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/qla3xxx.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +--
> =A0drivers/net/qlcnic/qlcnic_ctx.c =A0 =A0 | =A0 26 ++++++++++-------=
---
> =A0drivers/net/qlcnic/qlcnic_ethtool.c | =A0 =A02 +-
> =A0drivers/net/qlcnic/qlcnic_hw.c =A0 =A0 =A0| =A0 =A03 +-
> =A0drivers/net/qlcnic/qlcnic_main.c =A0 =A0| =A0 =A02 +-
> =A0drivers/net/qlge/qlge_main.c =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/s2io.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++=
++--------
> =A0drivers/net/sfc/siena.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/sis900.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/tokenring/madgemc.c =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/typhoon.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/vxge/vxge-config.c =A0 =A0 =A0| =A0 44 ++++++++++++---=
--------------------
> =A0drivers/net/vxge/vxge-traffic.c =A0 =A0 | =A0 =A06 ++--
> =A0drivers/net/wan/pc300_tty.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/xilinx_emaclite.c =A0 =A0 =A0 | =A0 =A04 +-
> =A0drivers/net/yellowfin.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 ++--
> =A042 files changed, 123 insertions(+), 142 deletions(-)
>
> diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
> index deaa8bc..0230fc2 100644
> --- a/drivers/net/a2065.c
> +++ b/drivers/net/a2065.c
> @@ -426,7 +426,7 @@ static irqreturn_t lance_interrupt (int irq, void=
 *dev_id)
> =A0 =A0 =A0 =A0volatile struct lance_regs *ll;
> =A0 =A0 =A0 =A0int csr0;
>
> - =A0 =A0 =A0 dev =3D (struct net_device *) dev_id;
> + =A0 =A0 =A0 dev =3D dev_id;
>
> =A0 =A0 =A0 =A0lp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0ll =3D lp->ll;
> diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltp=
c.c
> index e69eead..34ffb54 100644
> --- a/drivers/net/appletalk/ltpc.c
> +++ b/drivers/net/appletalk/ltpc.c
> @@ -652,9 +652,9 @@ static int do_write(struct net_device *dev, void =
*cbuf, int cbuflen,
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0if(i) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].cbuf =3D (unsigned char *) cbuf=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].cbuf =3D cbuf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].cbuflen =3D cbuflen;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].dbuf =3D (unsigned char *) dbuf=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].dbuf =3D dbuf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].dbuflen =3D dbuflen;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].QWrite =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].mailbox =3D i; =A0/* this shou=
ld be initted rather */
> @@ -676,9 +676,9 @@ static int do_read(struct net_device *dev, void *=
cbuf, int cbuflen,
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0if(i) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].cbuf =3D (unsigned char *) cbuf=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].cbuf =3D cbuf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].cbuflen =3D cbuflen;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].dbuf =3D (unsigned char *) dbuf=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qels[i].dbuf =3D dbuf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].dbuflen =3D dbuflen;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].QWrite =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qels[i].mailbox =3D i; =A0/* this shou=
ld be initted rather */
> diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e=
_main.c
> index 86a9122..c3c5db1 100644
> --- a/drivers/net/atl1e/atl1e_main.c
> +++ b/drivers/net/atl1e/atl1e_main.c
> @@ -800,8 +800,7 @@ static int atl1e_setup_ring_resources(struct atl1=
e_adapter *adapter)
> =A0 =A0 =A0 =A0/* Init TPD Ring */
> =A0 =A0 =A0 =A0tx_ring->dma =3D roundup(adapter->ring_dma, 8);
> =A0 =A0 =A0 =A0offset =3D tx_ring->dma - adapter->ring_dma;
> - =A0 =A0 =A0 tx_ring->desc =3D (struct atl1e_tpd_desc *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (adapter->ring_vir_addr=
 + offset);
> + =A0 =A0 =A0 tx_ring->desc =3D adapter->ring_vir_addr + offset;
> =A0 =A0 =A0 =A0size =3D sizeof(struct atl1e_tx_buffer) * (tx_ring->co=
unt);
> =A0 =A0 =A0 =A0tx_ring->tx_buffer =3D kzalloc(size, GFP_KERNEL);
> =A0 =A0 =A0 =A0if (tx_ring->tx_buffer =3D=3D NULL) {
> @@ -827,7 +826,7 @@ static int atl1e_setup_ring_resources(struct atl1=
e_adapter *adapter)
>
> =A0 =A0 =A0 =A0/* Init CMB dma address */
> =A0 =A0 =A0 =A0tx_ring->cmb_dma =3D adapter->ring_dma + offset;
> - =A0 =A0 =A0 tx_ring->cmb =A0 =A0 =3D (u32 *)(adapter->ring_vir_addr=
 + offset);
> + =A0 =A0 =A0 tx_ring->cmb =3D adapter->ring_vir_addr + offset;
> =A0 =A0 =A0 =A0offset +=3D sizeof(u32);
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < adapter->num_rx_queues; i++) {
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index 16249e9..24e1592 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -311,8 +311,7 @@ static s32 atl2_setup_ring_resources(struct atl2_=
adapter *adapter)
> =A0 =A0 =A0 =A0adapter->txd_dma =3D adapter->ring_dma ;
> =A0 =A0 =A0 =A0offset =3D (adapter->txd_dma & 0x7) ? (8 - (adapter->t=
xd_dma & 0x7)) : 0;
> =A0 =A0 =A0 =A0adapter->txd_dma +=3D offset;
> - =A0 =A0 =A0 adapter->txd_ring =3D (struct tx_pkt_header *) (adapter=
->ring_vir_addr +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset);
> + =A0 =A0 =A0 adapter->txd_ring =3D adapter->ring_vir_addr + offset;
>
> =A0 =A0 =A0 =A0/* Init TXS Ring */
> =A0 =A0 =A0 =A0adapter->txs_dma =3D adapter->txd_dma + adapter->txd_r=
ing_size;
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.=
c
> index 0c12c2d..30719f5 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -2334,8 +2334,7 @@ int be_cmd_get_cntl_attributes(struct be_adapte=
r *adapter)
>
> =A0 =A0 =A0 =A0status =3D be_mbox_notify_wait(adapter);
> =A0 =A0 =A0 =A0if (!status) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 attribs =3D (struct mgmt_controller_att=
rib *)( attribs_cmd.va +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 sizeof(struct be_cmd_resp_hdr));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 attribs =3D attribs_cmd.va + sizeof(str=
uct be_cmd_resp_hdr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->hba_port_num =3D attribs->hba=
_attribs.phy_port;
> =A0 =A0 =A0 =A0}
>
> diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_et=
htool.c
> index facfe3c..5572c78 100644
> --- a/drivers/net/benet/be_ethtool.c
> +++ b/drivers/net/benet/be_ethtool.c
> @@ -386,7 +386,7 @@ static int be_get_settings(struct net_device *net=
dev, struct ethtool_cmd *ecmd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D be_cmd_get_phy_info(adapter=
, &phy_cmd);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!status) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp =3D (struct be_cmd=
_resp_get_phy_info *) phy_cmd.va;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp =3D phy_cmd.va;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0intf_type =3D le16_to_=
cpu(resp->interface_type);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (intf_type) {
> @@ -690,7 +690,7 @@ be_read_eeprom(struct net_device *netdev, struct =
ethtool_eeprom *eeprom,
> =A0 =A0 =A0 =A0status =3D be_cmd_get_seeprom_data(adapter, &eeprom_cm=
d);
>
> =A0 =A0 =A0 =A0if (!status) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp =3D (struct be_cmd_resp_seeprom_re=
ad *) eeprom_cmd.va;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 resp =3D eeprom_cmd.va;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(data, resp->seeprom_data + eepr=
om->offset, eeprom->len);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0dma_free_coherent(&adapter->pdev->dev, eeprom_cmd.size=
, eeprom_cmd.va,
> diff --git a/drivers/net/bna/bfa_cee.c b/drivers/net/bna/bfa_cee.c
> index f7b789a..dcfbf08 100644
> --- a/drivers/net/bna/bfa_cee.c
> +++ b/drivers/net/bna/bfa_cee.c
> @@ -236,7 +236,7 @@ static void
> =A0bfa_cee_hbfail(void *arg)
> =A0{
> =A0 =A0 =A0 =A0struct bfa_cee *cee;
> - =A0 =A0 =A0 cee =3D (struct bfa_cee *) arg;
> + =A0 =A0 =A0 cee =3D arg;
>
> =A0 =A0 =A0 =A0if (cee->get_attr_pending =3D=3D true) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cee->get_attr_status =3D BFA_STATUS_FA=
ILED;
> diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
> index bbd39dc..3c47dc5 100644
> --- a/drivers/net/bna/cna.h
> +++ b/drivers/net/bna/cna.h
> @@ -74,7 +74,7 @@ typedef struct mac { u8 mac[MAC_ADDRLEN]; } mac_t;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bfa_q_next(_q) =3D bfa_q_next(*((struc=
t list_head **) _qe)); \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bfa_q_qe_init(*((struct list_head **) =
_qe)); =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0} else { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *((struct list_head **) (_qe)) =3D (str=
uct list_head *) NULL; \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *((struct list_head **)(_qe)) =3D NULL;=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 \
> =A0}
>
> diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_=
shmcore.c
> index 731aa11..d4b26fb 100644
> --- a/drivers/net/caif/caif_shmcore.c
> +++ b/drivers/net/caif/caif_shmcore.c
> @@ -134,7 +134,7 @@ int caif_shmdrv_rx_cb(u32 mbx_msg, void *priv)
> =A0 =A0 =A0 =A0u32 avail_emptybuff =3D 0;
> =A0 =A0 =A0 =A0unsigned long flags =3D 0;
>
> - =A0 =A0 =A0 pshm_drv =3D (struct shmdrv_layer *)priv;
> + =A0 =A0 =A0 pshm_drv =3D priv;
>
> =A0 =A0 =A0 =A0/* Check for received buffers. */
> =A0 =A0 =A0 =A0if (mbx_msg & SHM_FULL_MASK) {
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> index 363c7f3..8548cbe 100644
> --- a/drivers/net/cnic.c
> +++ b/drivers/net/cnic.c
> @@ -4290,7 +4290,7 @@ static void cnic_init_bnx2_tx_ring(struct cnic_=
dev *dev)
> =A0 =A0 =A0 =A0val =3D BNX2_L2CTX_CMD_TYPE_TYPE_L2 | (8 << 16);
> =A0 =A0 =A0 =A0cnic_ctx_wr(dev, cid_addr, offset1, val);
>
> - =A0 =A0 =A0 txbd =3D (struct tx_bd *) udev->l2_ring;
> + =A0 =A0 =A0 txbd =3D udev->l2_ring;
>
> =A0 =A0 =A0 =A0buf_map =3D udev->l2_buf_map;
> =A0 =A0 =A0 =A0for (i =3D 0; i < MAX_TX_DESC_CNT; i++, txbd++) {
> @@ -4349,7 +4349,7 @@ static void cnic_init_bnx2_rx_ring(struct cnic_=
dev *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D BNX2_L2CTX_L2_STATUSB_NUM(sb_i=
d);
> =A0 =A0 =A0 =A0cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_HOST_BDIDX, val)=
;
>
> - =A0 =A0 =A0 rxbd =3D (struct rx_bd *) (udev->l2_ring + BCM_PAGE_SIZ=
E);
> + =A0 =A0 =A0 rxbd =3D udev->l2_ring + BCM_PAGE_SIZE;
> =A0 =A0 =A0 =A0for (i =3D 0; i < MAX_RX_DESC_CNT; i++, rxbd++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dma_addr_t buf_map;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int n =3D (i % cp->l2_rx_ring_size) + =
1;
> diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cx=
gb3_offload.c
> index 862804f..9db9068 100644
> --- a/drivers/net/cxgb3/cxgb3_offload.c
> +++ b/drivers/net/cxgb3/cxgb3_offload.c
> @@ -567,7 +567,7 @@ static void t3_process_tid_release_list(struct wo=
rk_struct *work)
> =A0 =A0 =A0 =A0while (td->tid_release_list) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct t3c_tid_entry *p =3D td->tid_re=
lease_list;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 td->tid_release_list =3D (struct t3c_ti=
d_entry *)p->ctx;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 td->tid_release_list =3D p->ctx;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_bh(&td->tid_release_lock);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D alloc_skb(sizeof(struct cpl_ti=
d_release),
> diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.=
c
> index ae47f23..dca9d33 100644
> --- a/drivers/net/davinci_cpdma.c
> +++ b/drivers/net/davinci_cpdma.c
> @@ -167,7 +167,7 @@ cpdma_desc_pool_create(struct device *dev, u32 ph=
ys, u32 hw_addr,
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pool->cpumap =3D dma_alloc_coherent(de=
v, size, &pool->phys,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_KERNEL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pool->iomap =3D (void __force __iomem *=
)pool->cpumap;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pool->iomap =3D pool->cpumap;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pool->hw_addr =3D pool->phys;
> =A0 =A0 =A0 =A0}
>
> diff --git a/drivers/net/declance.c b/drivers/net/declance.c
> index 219eb5a..cabd3a5 100644
> --- a/drivers/net/declance.c
> +++ b/drivers/net/declance.c
> @@ -326,15 +326,18 @@ static void load_csrs(struct lance_private *lp)
> =A0*/
> =A0static void cp_to_buf(const int type, void *to, const void *from, =
int len)
> =A0{
> - =A0 =A0 =A0 unsigned short *tp, *fp, clen;
> - =A0 =A0 =A0 unsigned char *rtp, *rfp;
> + =A0 =A0 =A0 unsigned short *tp;
> + =A0 =A0 =A0 const unsigned short *fp;
> + =A0 =A0 =A0 unsigned short clen;
> + =A0 =A0 =A0 unsigned char *rtp;
> + =A0 =A0 =A0 const unsigned char *rfp;
>
> =A0 =A0 =A0 =A0if (type =3D=3D PMAD_LANCE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(to, from, len);
> =A0 =A0 =A0 =A0} else if (type =3D=3D PMAX_LANCE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clen =3D len >> 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D (unsigned short *) to;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D (unsigned short *) from;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D to;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D from;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (clen--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*tp++ =3D *fp++;
> @@ -342,8 +345,8 @@ static void cp_to_buf(const int type, void *to, c=
onst void *from, int len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clen =3D len & 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtp =3D (unsigned char *) tp;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rfp =3D (unsigned char *) fp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtp =3D tp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rfp =3D fp;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (clen--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*rtp++ =3D *rfp++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -352,8 +355,8 @@ static void cp_to_buf(const int type, void *to, c=
onst void *from, int len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * copy 16 Byte chunks
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clen =3D len >> 4;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D (unsigned short *) to;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D (unsigned short *) from;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D to;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D from;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (clen--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*tp++ =3D *fp++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*tp++ =3D *fp++;
> @@ -382,15 +385,18 @@ static void cp_to_buf(const int type, void *to,=
 const void *from, int len)
>
> =A0static void cp_from_buf(const int type, void *to, const void *from=
, int len)
> =A0{
> - =A0 =A0 =A0 unsigned short *tp, *fp, clen;
> - =A0 =A0 =A0 unsigned char *rtp, *rfp;
> + =A0 =A0 =A0 unsigned short *tp;
> + =A0 =A0 =A0 const unsigned short *fp;
> + =A0 =A0 =A0 unsigned short clen;
> + =A0 =A0 =A0 unsigned char *rtp;
> + =A0 =A0 =A0 const unsigned char *rfp;
>
> =A0 =A0 =A0 =A0if (type =3D=3D PMAD_LANCE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(to, from, len);
> =A0 =A0 =A0 =A0} else if (type =3D=3D PMAX_LANCE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clen =3D len >> 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D (unsigned short *) to;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D (unsigned short *) from;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D to;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D from;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (clen--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*tp++ =3D *fp++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fp++;
> @@ -398,8 +404,8 @@ static void cp_from_buf(const int type, void *to,=
 const void *from, int len)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clen =3D len & 1;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtp =3D (unsigned char *) tp;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rfp =3D (unsigned char *) fp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtp =3D tp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rfp =3D fp;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (clen--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*rtp++ =3D *rfp++;
> @@ -410,8 +416,8 @@ static void cp_from_buf(const int type, void *to,=
 const void *from, int len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * copy 16 Byte chunks
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clen =3D len >> 4;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D (unsigned short *) to;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D (unsigned short *) from;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp =3D to;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D from;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (clen--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*tp++ =3D *fp++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*tp++ =3D *fp++;
> diff --git a/drivers/net/depca.c b/drivers/net/depca.c
> index 8b0084d..d54a0e9 100644
> --- a/drivers/net/depca.c
> +++ b/drivers/net/depca.c
> @@ -708,11 +708,11 @@ static int __init depca_hw_init (struct net_dev=
ice *dev, struct device *device)
>
> =A0 =A0 =A0 =A0/* Tx & Rx descriptors (aligned to a quadword boundary=
) */
> =A0 =A0 =A0 =A0offset =3D (offset + DEPCA_ALIGN) & ~DEPCA_ALIGN;
> - =A0 =A0 =A0 lp->rx_ring =3D (struct depca_rx_desc __iomem *) (lp->s=
h_mem + offset);
> + =A0 =A0 =A0 lp->rx_ring =3D lp->sh_mem + offset;
> =A0 =A0 =A0 =A0lp->rx_ring_offset =3D offset;
>
> =A0 =A0 =A0 =A0offset +=3D (sizeof(struct depca_rx_desc) * NUM_RX_DES=
C);
> - =A0 =A0 =A0 lp->tx_ring =3D (struct depca_tx_desc __iomem *) (lp->s=
h_mem + offset);
> + =A0 =A0 =A0 lp->tx_ring =3D lp->sh_mem + offset;
> =A0 =A0 =A0 =A0lp->tx_ring_offset =3D offset;
>
> =A0 =A0 =A0 =A0offset +=3D (sizeof(struct depca_tx_desc) * NUM_TX_DES=
C);
> diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
> index c445457..05e64b2 100644
> --- a/drivers/net/dl2k.c
> +++ b/drivers/net/dl2k.c
> @@ -221,13 +221,13 @@ rio_probe1 (struct pci_dev *pdev, const struct =
pci_device_id *ent)
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent (pdev, TX_TOTAL_SI=
ZE, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_iounmap;
> - =A0 =A0 =A0 np->tx_ring =3D (struct netdev_desc *) ring_space;
> + =A0 =A0 =A0 np->tx_ring =3D ring_space;
> =A0 =A0 =A0 =A0np->tx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent (pdev, RX_TOTAL_SI=
ZE, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_unmap_tx;
> - =A0 =A0 =A0 np->rx_ring =3D (struct netdev_desc *) ring_space;
> + =A0 =A0 =A0 np->rx_ring =3D ring_space;
> =A0 =A0 =A0 =A0np->rx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0/* Parse eeprom data */
> diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.=
c
> index cd44bb8..95b9f4f 100644
> --- a/drivers/net/ehea/ehea_qmr.c
> +++ b/drivers/net/ehea/ehea_qmr.c
> @@ -331,7 +331,7 @@ struct ehea_eqe *ehea_poll_eq(struct ehea_eq *eq)
> =A0 =A0 =A0 =A0unsigned long flags;
>
> =A0 =A0 =A0 =A0spin_lock_irqsave(&eq->spinlock, flags);
> - =A0 =A0 =A0 eqe =3D (struct ehea_eqe *)hw_eqit_eq_get_inc_valid(&eq=
->hw_queue);
> + =A0 =A0 =A0 eqe =3D hw_eqit_eq_get_inc_valid(&eq->hw_queue);
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&eq->spinlock, flags);
>
> =A0 =A0 =A0 =A0return eqe;
> diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
> index c353bf3..814c187 100644
> --- a/drivers/net/epic100.c
> +++ b/drivers/net/epic100.c
> @@ -391,13 +391,13 @@ static int __devinit epic_init_one (struct pci_=
dev *pdev,
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, TX_TOTAL_SIZ=
E, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_iounmap;
> - =A0 =A0 =A0 ep->tx_ring =3D (struct epic_tx_desc *)ring_space;
> + =A0 =A0 =A0 ep->tx_ring =3D ring_space;
> =A0 =A0 =A0 =A0ep->tx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, RX_TOTAL_SIZ=
E, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_unmap_tx;
> - =A0 =A0 =A0 ep->rx_ring =3D (struct epic_rx_desc *)ring_space;
> + =A0 =A0 =A0 ep->rx_ring =3D ring_space;
> =A0 =A0 =A0 =A0ep->rx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0if (dev->mem_start) {
> diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
> index dd54abe..fa8677c 100644
> --- a/drivers/net/fealnx.c
> +++ b/drivers/net/fealnx.c
> @@ -566,7 +566,7 @@ static int __devinit fealnx_init_one(struct pci_d=
ev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free_dev;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 np->rx_ring =3D (struct fealnx_desc *)ring_space;
> + =A0 =A0 =A0 np->rx_ring =3D ring_space;
> =A0 =A0 =A0 =A0np->rx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, TX_TOTAL_SIZ=
E, &ring_dma);
> @@ -574,7 +574,7 @@ static int __devinit fealnx_init_one(struct pci_d=
ev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free_rx;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 np->tx_ring =3D (struct fealnx_desc *)ring_space;
> + =A0 =A0 =A0 np->tx_ring =3D ring_space;
> =A0 =A0 =A0 =A0np->tx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0/* find the connected MII xcvrs */
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index ff60b23..3564551 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -266,7 +266,7 @@ static int gfar_alloc_skb_resources(struct net_de=
vice *ndev)
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < priv->num_tx_queues; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tx_queue =3D priv->tx_queue[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_queue->tx_bd_base =3D (struct txbd8 =
*) vaddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_queue->tx_bd_base =3D vaddr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tx_queue->tx_bd_dma_base =3D addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tx_queue->dev =3D ndev;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* enet DMA only understands physical =
addresses */
> @@ -277,7 +277,7 @@ static int gfar_alloc_skb_resources(struct net_de=
vice *ndev)
> =A0 =A0 =A0 =A0/* Start the rx descriptor ring where the tx ring leav=
es off */
> =A0 =A0 =A0 =A0for (i =3D 0; i < priv->num_rx_queues; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_queue =3D priv->rx_queue[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_queue->rx_bd_base =3D (struct rxbd8 =
*) vaddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_queue->rx_bd_base =3D vaddr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_queue->rx_bd_dma_base =3D addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_queue->dev =3D ndev;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr =A0 =A0+=3D sizeof (struct rxbd8)=
 * rx_queue->rx_ring_size;
> diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
> index a09041a..c274b3d 100644
> --- a/drivers/net/hamachi.c
> +++ b/drivers/net/hamachi.c
> @@ -648,13 +648,13 @@ static int __devinit hamachi_init_one (struct p=
ci_dev *pdev,
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, TX_TOTAL_SIZ=
E, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_cleardev;
> - =A0 =A0 =A0 hmp->tx_ring =3D (struct hamachi_desc *)ring_space;
> + =A0 =A0 =A0 hmp->tx_ring =3D ring_space;
> =A0 =A0 =A0 =A0hmp->tx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, RX_TOTAL_SIZ=
E, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_unmap_tx;
> - =A0 =A0 =A0 hmp->rx_ring =3D (struct hamachi_desc *)ring_space;
> + =A0 =A0 =A0 hmp->rx_ring =3D ring_space;
> =A0 =A0 =A0 =A0hmp->rx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0/* Check for options being passed in */
> diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
> index c685a46..4286e67 100644
> --- a/drivers/net/macmace.c
> +++ b/drivers/net/macmace.c
> @@ -221,7 +221,7 @@ static int __devinit mace_probe(struct platform_d=
evice *pdev)
> =A0 =A0 =A0 =A0SET_NETDEV_DEV(dev, &pdev->dev);
>
> =A0 =A0 =A0 =A0dev->base_addr =3D (u32)MACE_BASE;
> - =A0 =A0 =A0 mp->mace =3D (volatile struct mace *) MACE_BASE;
> + =A0 =A0 =A0 mp->mace =3D MACE_BASE;
>
> =A0 =A0 =A0 =A0dev->irq =3D IRQ_MAC_MACE;
> =A0 =A0 =A0 =A0mp->dma_intr =3D IRQ_MAC_MACE_DMA;
> diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
> index 277215f..5197b50 100644
> --- a/drivers/net/mlx4/en_rx.c
> +++ b/drivers/net/mlx4/en_rx.c
> @@ -859,7 +859,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv =
*priv)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->=
rx_ring[0].cqn, &context);
>
> =A0 =A0 =A0 =A0ptr =3D ((void *) &context) + 0x3c;
> - =A0 =A0 =A0 rss_context =3D (struct mlx4_en_rss_context *) ptr;
> + =A0 =A0 =A0 rss_context =3D ptr;
> =A0 =A0 =A0 =A0rss_context->base_qpn =3D cpu_to_be32(ilog2(priv->rx_r=
ing_num) << 24 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(rss_map->base_qpn));
> =A0 =A0 =A0 =A0rss_context->default_qpn =3D cpu_to_be32(rss_map->base=
_qpn);
> diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
> index b229acf..6e03de0 100644
> --- a/drivers/net/mlx4/en_tx.c
> +++ b/drivers/net/mlx4/en_tx.c
> @@ -238,8 +238,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_pr=
iv *priv,
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!tx_info->inl) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((void *) data >=3D=
 end) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D=
 (struct mlx4_wqe_data_seg *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 (ring->buf + ((void *) data - end));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D=
 ring->buf + ((void *)data - end);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tx_info->linear) {
> @@ -253,7 +252,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_pr=
iv *priv,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i < frag=
s; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Che=
ck for wraparound before unmapping */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((v=
oid *) data >=3D end)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 data =3D (struct mlx4_wqe_data_seg *) ring->buf;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 data =3D ring->buf;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0frag =3D=
 &skb_shinfo(skb)->frags[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pci_un=
map_page(mdev->pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0(dma_addr_t) be64_to_cpu(data->addr),
> diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
> index 53aeea4..0f4cb88 100644
> --- a/drivers/net/myri_sbus.c
> +++ b/drivers/net/myri_sbus.c
> @@ -1041,8 +1041,7 @@ static int __devinit myri_sbus_probe(struct pla=
tform_device *op)
>
> =A0 =A0 =A0 =A0DET(("Shared memory base is %04x, ", mp->shmem_base));
>
> - =A0 =A0 =A0 mp->shmem =3D (struct myri_shmem __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (mp->lanai + (mp->shmem_base * 2));
> + =A0 =A0 =A0 mp->shmem =3D mp->lanai + (mp->shmem_base * 2);
> =A0 =A0 =A0 =A0DET(("shmem mapped at %p\n", mp->shmem));
>
> =A0 =A0 =A0 =A0mp->rqack =A0 =A0 =A0 =3D &mp->shmem->channel.recvqa;
> diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen=
/netxen_nic_ctx.c
> index f16966a..a925392 100644
> --- a/drivers/net/netxen/netxen_nic_ctx.c
> +++ b/drivers/net/netxen/netxen_nic_ctx.c
> @@ -163,7 +163,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *ad=
apter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rq_siz=
e, &hostrq_phys_addr);
> =A0 =A0 =A0 =A0if (addr =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> - =A0 =A0 =A0 prq =3D (nx_hostrq_rx_ctx_t *)addr;
> + =A0 =A0 =A0 prq =3D addr;
>
> =A0 =A0 =A0 =A0addr =3D pci_alloc_consistent(adapter->pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rsp_size, &cardrsp_phy=
s_addr);
> @@ -171,7 +171,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *ad=
apter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_rq;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 prsp =3D (nx_cardrsp_rx_ctx_t *)addr;
> + =A0 =A0 =A0 prsp =3D addr;
>
> =A0 =A0 =A0 =A0prq->host_rsp_dma_addr =3D cpu_to_le64(cardrsp_phys_ad=
dr);
>
> @@ -318,10 +318,10 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *=
adapter)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0memset(rq_addr, 0, rq_size);
> - =A0 =A0 =A0 prq =3D (nx_hostrq_tx_ctx_t *)rq_addr;
> + =A0 =A0 =A0 prq =3D rq_addr;
>
> =A0 =A0 =A0 =A0memset(rsp_addr, 0, rsp_size);
> - =A0 =A0 =A0 prsp =3D (nx_cardrsp_tx_ctx_t *)rsp_addr;
> + =A0 =A0 =A0 prsp =3D rsp_addr;
>
> =A0 =A0 =A0 =A0prq->host_rsp_dma_addr =3D cpu_to_le64(rsp_phys_addr);
>
> @@ -629,7 +629,7 @@ int netxen_alloc_hw_resources(struct netxen_adapt=
er *adapter)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0memset(addr, 0, sizeof(struct netxen_ring_ctx));
> - =A0 =A0 =A0 recv_ctx->hwctx =3D (struct netxen_ring_ctx *)addr;
> + =A0 =A0 =A0 recv_ctx->hwctx =3D addr;
> =A0 =A0 =A0 =A0recv_ctx->hwctx->ctx_id =3D cpu_to_le32(port);
> =A0 =A0 =A0 =A0recv_ctx->hwctx->cmd_consumer_offset =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpu_to_le64(recv_ctx->phys_addr +
> @@ -648,7 +648,7 @@ int netxen_alloc_hw_resources(struct netxen_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 tx_ring->desc_head =3D (struct cmd_desc_type0 *)addr;
> + =A0 =A0 =A0 tx_ring->desc_head =3D addr;
>
> =A0 =A0 =A0 =A0for (ring =3D 0; ring < adapter->max_rds_rings; ring++=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rds_ring =3D &recv_ctx->rds_rings[ring=
];
> @@ -662,7 +662,7 @@ int netxen_alloc_hw_resources(struct netxen_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rds_ring->desc_head =3D (struct rcv_des=
c *)addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rds_ring->desc_head =3D addr;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (NX_IS_REVISION_P2(adapter->ahw.rev=
ision_id))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rds_ring->crb_rcv_prod=
ucer =3D
> @@ -683,7 +683,7 @@ int netxen_alloc_hw_resources(struct netxen_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sds_ring->desc_head =3D (struct status_=
desc *)addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sds_ring->desc_head =3D addr;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (NX_IS_REVISION_P2(adapter->ahw.rev=
ision_id)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sds_ring->crb_sts_cons=
umer =3D
> diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
> index 89f7540..abd1693 100644
> --- a/drivers/net/pxa168_eth.c
> +++ b/drivers/net/pxa168_eth.c
> @@ -502,7 +502,7 @@ static int add_del_hash_entry(struct pxa168_eth_p=
rivate *pep,
> =A0 =A0 =A0 =A0 * Pick the appropriate table, start scanning for free=
/reusable
> =A0 =A0 =A0 =A0 * entries at the index obtained by hashing the specif=
ied MAC address
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 start =3D (struct addr_table_entry *)(pep->htpr);
> + =A0 =A0 =A0 start =3D pep->htpr;
> =A0 =A0 =A0 =A0entry =3D start + hash_function(mac_addr);
> =A0 =A0 =A0 =A0for (i =3D 0; i < HOP_NUMBER; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(le32_to_cpu(entry->lo) & HASH_EN=
TRY_VALID)) {
> diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> index 771bb61..2f69140 100644
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -2873,7 +2873,7 @@ static int ql_alloc_mem_resources(struct ql3_ad=
apter *qdev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 PAGE_SIZE, &qdev->shadow_reg_phy_addr);
>
> =A0 =A0 =A0 =A0if (qdev->shadow_reg_virt_addr !=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdev->preq_consumer_index =3D (u16 *) q=
dev->shadow_reg_virt_addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdev->preq_consumer_index =3D qdev->sha=
dow_reg_virt_addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qdev->req_consumer_index_phy_addr_high=
 =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MS_64BITS(qdev->shadow=
_reg_phy_addr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qdev->req_consumer_index_phy_addr_low =
=3D
> @@ -3114,8 +3114,7 @@ static int ql_adapter_initialize(struct ql3_ada=
pter *qdev)
> =A0 =A0 =A0 =A0qdev->small_buf_release_cnt =3D 8;
> =A0 =A0 =A0 =A0qdev->lrg_buf_q_producer_index =3D qdev->num_lbufq_ent=
ries - 1;
> =A0 =A0 =A0 =A0qdev->lrg_buf_release_cnt =3D 8;
> - =A0 =A0 =A0 qdev->lrg_buf_next_free =3D
> - =A0 =A0 =A0 =A0 =A0 (struct bufq_addr_element *)qdev->lrg_buf_q_vir=
t_addr;
> + =A0 =A0 =A0 qdev->lrg_buf_next_free =3D qdev->lrg_buf_q_virt_addr;
> =A0 =A0 =A0 =A0qdev->small_buf_index =3D 0;
> =A0 =A0 =A0 =A0qdev->lrg_buf_index =3D 0;
> =A0 =A0 =A0 =A0qdev->lrg_buf_free_count =3D 0;
> diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlc=
nic_ctx.c
> index bab041a..c77024f 100644
> --- a/drivers/net/qlcnic/qlcnic_ctx.c
> +++ b/drivers/net/qlcnic/qlcnic_ctx.c
> @@ -126,7 +126,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic=
_adapter *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 tmp_tmpl =3D (struct qlcnic_dump_template_hdr *) tmp_ad=
dr;
> + =A0 =A0 =A0 tmp_tmpl =3D tmp_addr;
> =A0 =A0 =A0 =A0csum =3D qlcnic_temp_checksum((uint32_t *) tmp_addr, t=
emp_size);
> =A0 =A0 =A0 =A0if (csum) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&adapter->pdev->dev,
> @@ -139,7 +139,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic=
_adapter *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 tmp_buf =3D (u32 *) tmp_addr;
> + =A0 =A0 =A0 tmp_buf =3D tmp_addr;
> =A0 =A0 =A0 =A0template =3D (u32 *) ahw->fw_dump.tmpl_hdr;
> =A0 =A0 =A0 =A0for (i =3D 0; i < temp_size/sizeof(u32); i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*template++ =3D __le32_to_cpu(*tmp_buf=
++);
> @@ -214,7 +214,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter=
 *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&hostrq_phys_addr, GFP=
_KERNEL);
> =A0 =A0 =A0 =A0if (addr =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> - =A0 =A0 =A0 prq =3D (struct qlcnic_hostrq_rx_ctx *)addr;
> + =A0 =A0 =A0 prq =3D addr;
>
> =A0 =A0 =A0 =A0addr =3D dma_alloc_coherent(&adapter->pdev->dev, rsp_s=
ize,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&cardrsp_phys_addr, GF=
P_KERNEL);
> @@ -222,7 +222,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter=
 *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_rq;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 prsp =3D (struct qlcnic_cardrsp_rx_ctx *)addr;
> + =A0 =A0 =A0 prsp =3D addr;
>
> =A0 =A0 =A0 =A0prq->host_rsp_dma_addr =3D cpu_to_le64(cardrsp_phys_ad=
dr);
>
> @@ -380,10 +380,10 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapt=
er *adapter)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0memset(rq_addr, 0, rq_size);
> - =A0 =A0 =A0 prq =3D (struct qlcnic_hostrq_tx_ctx *)rq_addr;
> + =A0 =A0 =A0 prq =3D rq_addr;
>
> =A0 =A0 =A0 =A0memset(rsp_addr, 0, rsp_size);
> - =A0 =A0 =A0 prsp =3D (struct qlcnic_cardrsp_tx_ctx *)rsp_addr;
> + =A0 =A0 =A0 prsp =3D rsp_addr;
>
> =A0 =A0 =A0 =A0prq->host_rsp_dma_addr =3D cpu_to_le64(rsp_phys_addr);
>
> @@ -493,7 +493,7 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 tx_ring->desc_head =3D (struct cmd_desc_type0 *)addr;
> + =A0 =A0 =A0 tx_ring->desc_head =3D addr;
>
> =A0 =A0 =A0 =A0for (ring =3D 0; ring < adapter->max_rds_rings; ring++=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rds_ring =3D &recv_ctx->rds_rings[ring=
];
> @@ -506,7 +506,7 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rds_ring->desc_head =3D (struct rcv_des=
c *)addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rds_ring->desc_head =3D addr;
>
> =A0 =A0 =A0 =A0}
>
> @@ -522,7 +522,7 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_free;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sds_ring->desc_head =3D (struct status_=
desc *)addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sds_ring->desc_head =3D addr;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return 0;
> @@ -662,7 +662,7 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *ad=
apter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0memset(nic_info_addr, 0, nic_size);
>
> - =A0 =A0 =A0 nic_info =3D (struct qlcnic_info *) nic_info_addr;
> + =A0 =A0 =A0 nic_info =3D nic_info_addr;
> =A0 =A0 =A0 =A0err =3D qlcnic_issue_cmd(adapter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->ahw->pci_func=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->fw_hal_versio=
n,
> @@ -720,7 +720,7 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *ad=
apter, struct qlcnic_info *nic)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> =A0 =A0 =A0 =A0memset(nic_info_addr, 0, nic_size);
> - =A0 =A0 =A0 nic_info =3D (struct qlcnic_info *)nic_info_addr;
> + =A0 =A0 =A0 nic_info =3D nic_info_addr;
>
> =A0 =A0 =A0 =A0nic_info->pci_func =3D cpu_to_le16(nic->pci_func);
> =A0 =A0 =A0 =A0nic_info->op_mode =3D cpu_to_le16(nic->op_mode);
> @@ -769,7 +769,7 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *ad=
apter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0memset(pci_info_addr, 0, pci_size);
>
> - =A0 =A0 =A0 npar =3D (struct qlcnic_pci_info *) pci_info_addr;
> + =A0 =A0 =A0 npar =3D pci_info_addr;
> =A0 =A0 =A0 =A0err =3D qlcnic_issue_cmd(adapter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->ahw->pci_func=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->fw_hal_versio=
n,
> @@ -877,7 +877,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *=
adapter, const u8 func,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0QLCNIC_CDRP_CMD_GET_ES=
WITCH_STATS);
>
> =A0 =A0 =A0 =A0if (!err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats =3D (struct __qlcnic_esw_statisti=
cs *)stats_addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats =3D stats_addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0esw_stats->context_id =3D le16_to_cpu(=
stats->context_id);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0esw_stats->version =3D le16_to_cpu(sta=
ts->version);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0esw_stats->size =3D le16_to_cpu(stats-=
>size);
> diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic=
/qlcnic_ethtool.c
> index 9efc690..8ea8001 100644
> --- a/drivers/net/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/qlcnic/qlcnic_ethtool.c
> @@ -996,7 +996,7 @@ qlcnic_get_dump_data(struct net_device *netdev, s=
truct ethtool_dump *dump,
> =A0 =A0 =A0 =A0/* Copy template header first */
> =A0 =A0 =A0 =A0copy_sz =3D fw_dump->tmpl_hdr->size;
> =A0 =A0 =A0 =A0hdr_ptr =3D (u32 *) fw_dump->tmpl_hdr;
> - =A0 =A0 =A0 data =3D (u32 *) buffer;
> + =A0 =A0 =A0 data =3D buffer;
> =A0 =A0 =A0 =A0for (i =3D 0; i < copy_sz/sizeof(u32); i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*data++ =3D cpu_to_le32(*hdr_ptr++);
>
> diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcn=
ic_hw.c
> index e965661..ea0f11e 100644
> --- a/drivers/net/qlcnic/qlcnic_hw.c
> +++ b/drivers/net/qlcnic/qlcnic_hw.c
> @@ -1672,8 +1672,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapt=
er)
> =A0 =A0 =A0 =A0tmpl_hdr->sys_info[1] =3D adapter->fw_version;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < no_entries; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct qlcnic_dump_entry *) =
((void *) tmpl_hdr +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry_offset);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (void *)tmpl_hdr + entry_offs=
et;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(entry->hdr.mask & tmpl_hdr->drv_=
cap_mask)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry->hdr.flags |=3D =
QLCNIC_DUMP_SKIP;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry_offset +=3D entr=
y->hdr.offset;
> diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/ql=
cnic_main.c
> index 3ab7d2c..0a6c1c9 100644
> --- a/drivers/net/qlcnic/qlcnic_main.c
> +++ b/drivers/net/qlcnic/qlcnic_main.c
> @@ -1861,7 +1861,7 @@ qlcnic_alloc_lb_filters_mem(struct qlcnic_adapt=
er *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0adapter->fhash.fmax =3D QLCNIC_LB_MAX_FILTERS;
> - =A0 =A0 =A0 adapter->fhash.fhead =3D (struct hlist_head *)head;
> + =A0 =A0 =A0 adapter->fhash.fhead =3D head;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < adapter->fhash.fmax; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_HLIST_HEAD(&adapter->fhash.fhead[=
i]);
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_mai=
n.c
> index 930ae45..be89610 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -3096,7 +3096,7 @@ static int ql_start_rx_ring(struct ql_adapter *=
qdev, struct rx_ring *rx_ring)
> =A0 =A0 =A0 =A0if (rx_ring->lbq_len) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cqicb->flags |=3D FLAGS_LL; =A0 =A0 =A0=
 /* Load lbq values */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp =3D (u64)rx_ring->lbq_base_dma;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 base_indirect_ptr =3D (__le64 *) rx_rin=
g->lbq_base_indirect;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 base_indirect_ptr =3D rx_ring->lbq_base=
_indirect;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page_entries =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*base_indirect_ptr =3D=
 cpu_to_le64(tmp);
> @@ -3120,7 +3120,7 @@ static int ql_start_rx_ring(struct ql_adapter *=
qdev, struct rx_ring *rx_ring)
> =A0 =A0 =A0 =A0if (rx_ring->sbq_len) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cqicb->flags |=3D FLAGS_LS; =A0 =A0 =A0=
 /* Load sbq values */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp =3D (u64)rx_ring->sbq_base_dma;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 base_indirect_ptr =3D (__le64 *) rx_rin=
g->sbq_base_indirect;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 base_indirect_ptr =3D rx_ring->sbq_base=
_indirect;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page_entries =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*base_indirect_ptr =3D=
 cpu_to_le64(tmp);
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index df0d2c8..f4d80f9 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -841,7 +841,7 @@ static int init_shared_mem(struct s2io_nic *nic)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp_p_addr =3D ring->r=
x_blocks[j].block_dma_addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp_p_addr_next =3D ri=
ng->rx_blocks[next].block_dma_addr;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pre_rxd_blk =3D (struct=
 RxD_block *)tmp_v_addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pre_rxd_blk =3D tmp_v_a=
ddr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pre_rxd_blk->reserved_=
2_pNext_RxD_block =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsig=
ned long)tmp_v_addr_next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pre_rxd_blk->pNext_RxD=
_Blk_physical =3D
> @@ -918,7 +918,7 @@ static int init_shared_mem(struct s2io_nic *nic)
> =A0 =A0 =A0 =A0mac_control->stats_mem_sz =3D size;
>
> =A0 =A0 =A0 =A0tmp_v_addr =3D mac_control->stats_mem;
> - =A0 =A0 =A0 mac_control->stats_info =3D (struct stat_block *)tmp_v_=
addr;
> + =A0 =A0 =A0 mac_control->stats_info =3D tmp_v_addr;
> =A0 =A0 =A0 =A0memset(tmp_v_addr, 0, size);
> =A0 =A0 =A0 =A0DBG_PRINT(INIT_DBG, "%s: Ring Mem PHY: 0x%llx\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_name(&nic->pdev->dev), (unsigned l=
ong long)tmp_p_addr);
> @@ -2439,7 +2439,7 @@ static void free_tx_buffers(struct s2io_nic *ni=
c)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_irqsave(&fifo->tx_lock, flag=
s);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (j =3D 0; j < tx_cfg->fifo_len; j+=
+) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txdp =3D (struct TxD *)=
fifo->list_info[j].list_virt_addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txdp =3D fifo->list_inf=
o[j].list_virt_addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D s2io_txdl_gets=
kb(&mac_control->fifos[i], txdp, j);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swstat=
s->mem_freed +=3D skb->truesize;
> @@ -3075,8 +3075,7 @@ static void tx_intr_handler(struct fifo_info *f=
ifo_data)
>
> =A0 =A0 =A0 =A0get_info =3D fifo_data->tx_curr_get_info;
> =A0 =A0 =A0 =A0memcpy(&put_info, &fifo_data->tx_curr_put_info, sizeof=
(put_info));
> - =A0 =A0 =A0 txdlp =3D (struct TxD *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fifo_data->list_info[get_info.offset].l=
ist_virt_addr;
> + =A0 =A0 =A0 txdlp =3D fifo_data->list_info[get_info.offset].list_vi=
rt_addr;
> =A0 =A0 =A0 =A0while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (get_info.offset !=3D put_info.offset) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (txdlp->Host_Control)) {
> @@ -3129,8 +3128,7 @@ static void tx_intr_handler(struct fifo_info *f=
ifo_data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_info.offset++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (get_info.offset =3D=3D get_info.fi=
fo_len + 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_info.offset =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 txdlp =3D (struct TxD *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fifo_data->list_info[ge=
t_info.offset].list_virt_addr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 txdlp =3D fifo_data->list_info[get_info=
=2Eoffset].list_virt_addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fifo_data->tx_curr_get_info.offset =3D=
 get_info.offset;
> =A0 =A0 =A0 =A0}
>
> @@ -4163,7 +4161,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *sk=
b, struct net_device *dev)
>
> =A0 =A0 =A0 =A0put_off =3D (u16)fifo->tx_curr_put_info.offset;
> =A0 =A0 =A0 =A0get_off =3D (u16)fifo->tx_curr_get_info.offset;
> - =A0 =A0 =A0 txdp =3D (struct TxD *)fifo->list_info[put_off].list_vi=
rt_addr;
> + =A0 =A0 =A0 txdp =3D fifo->list_info[put_off].list_virt_addr;
>
> =A0 =A0 =A0 =A0queue_len =3D fifo->tx_curr_put_info.fifo_len + 1;
> =A0 =A0 =A0 =A0/* Avoid "put" pointer going beyond "get" pointer */
> @@ -7972,9 +7970,7 @@ s2io_init_nic(struct pci_dev *pdev, const struc=
t pci_device_id *pre)
>
> =A0 =A0 =A0 =A0/* Initializing the BAR1 address as the start of the F=
IFO pointer. */
> =A0 =A0 =A0 =A0for (j =3D 0; j < MAX_TX_FIFOS; j++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mac_control->tx_FIFO_start[j] =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct TxFIFO_element =
__iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (sp->bar1 + (j * 0x0002=
0000));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mac_control->tx_FIFO_start[j] =3D sp->b=
ar1 + (j * 0x00020000);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* =A0Driver entry points */
> diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
> index fb4721f..a66818e 100644
> --- a/drivers/net/sfc/siena.c
> +++ b/drivers/net/sfc/siena.c
> @@ -400,7 +400,7 @@ static int siena_try_update_nic_stats(struct efx_=
nic *efx)
> =A0 =A0 =A0 =A0u64 generation_end;
>
> =A0 =A0 =A0 =A0mac_stats =3D &efx->mac_stats;
> - =A0 =A0 =A0 dma_stats =3D (u64 *)efx->stats_buffer.addr;
> + =A0 =A0 =A0 dma_stats =3D efx->stats_buffer.addr;
>
> =A0 =A0 =A0 =A0generation_end =3D dma_stats[MC_CMD_MAC_GENERATION_END=
];
> =A0 =A0 =A0 =A0if (generation_end =3D=3D STATS_GENERATION_INVALID)
> diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
> index 484f795..658a192 100644
> --- a/drivers/net/sis900.c
> +++ b/drivers/net/sis900.c
> @@ -482,7 +482,7 @@ static int __devinit sis900_probe(struct pci_dev =
*pci_dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_cleardev;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 sis_priv->tx_ring =3D (BufferDesc *)ring_space;
> + =A0 =A0 =A0 sis_priv->tx_ring =3D ring_space;
> =A0 =A0 =A0 =A0sis_priv->tx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pci_dev, RX_TOTAL_=
SIZE, &ring_dma);
> @@ -490,7 +490,7 @@ static int __devinit sis900_probe(struct pci_dev =
*pci_dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_unmap_tx;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 sis_priv->rx_ring =3D (BufferDesc *)ring_space;
> + =A0 =A0 =A0 sis_priv->rx_ring =3D ring_space;
> =A0 =A0 =A0 =A0sis_priv->rx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0/* The SiS900-specific entries in the device structure=
=2E */
> diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/=
madgemc.c
> index 2bedc0a..6153cfd 100644
> --- a/drivers/net/tokenring/madgemc.c
> +++ b/drivers/net/tokenring/madgemc.c
> @@ -418,7 +418,7 @@ static irqreturn_t madgemc_interrupt(int irq, voi=
d *dev_id)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return IRQ_NONE;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 dev =3D (struct net_device *)dev_id;
> + =A0 =A0 =A0 dev =3D dev_id;
>
> =A0 =A0 =A0 =A0/* Make sure its really us. -- the Madge way */
> =A0 =A0 =A0 =A0pending =3D inb(dev->base_addr + MC_CONTROL_REG0);
> diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
> index 3de4283..1d5091a 100644
> --- a/drivers/net/typhoon.c
> +++ b/drivers/net/typhoon.c
> @@ -2367,7 +2367,7 @@ typhoon_init_one(struct pci_dev *pdev, const st=
ruct pci_device_id *ent)
>
> =A0 =A0 =A0 =A0dev->irq =3D pdev->irq;
> =A0 =A0 =A0 =A0tp =3D netdev_priv(dev);
> - =A0 =A0 =A0 tp->shared =3D (struct typhoon_shared *) shared;
> + =A0 =A0 =A0 tp->shared =3D shared;
> =A0 =A0 =A0 =A0tp->shared_dma =3D shared_dma;
> =A0 =A0 =A0 =A0tp->pdev =3D pdev;
> =A0 =A0 =A0 =A0tp->tx_pdev =3D pdev;
> diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-c=
onfig.c
> index 32763b2..857618a 100644
> --- a/drivers/net/vxge/vxge-config.c
> +++ b/drivers/net/vxge/vxge-config.c
> @@ -582,7 +582,7 @@ __vxge_hw_device_toc_get(void __iomem *bar0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto exit;
>
> =A0 =A0 =A0 =A0val64 =3D readq(&legacy_reg->toc_first_pointer);
> - =A0 =A0 =A0 toc =3D (struct vxge_hw_toc_reg __iomem *)(bar0+val64);
> + =A0 =A0 =A0 toc =3D bar0 + val64;
> =A0exit:
> =A0 =A0 =A0 =A0return toc;
> =A0}
> @@ -600,7 +600,7 @@ __vxge_hw_device_reg_addr_get(struct __vxge_hw_de=
vice *hldev)
> =A0 =A0 =A0 =A0u32 i;
> =A0 =A0 =A0 =A0enum vxge_hw_status status =3D VXGE_HW_OK;
>
> - =A0 =A0 =A0 hldev->legacy_reg =3D (struct vxge_hw_legacy_reg __iome=
m *)hldev->bar0;
> + =A0 =A0 =A0 hldev->legacy_reg =3D hldev->bar0;
>
> =A0 =A0 =A0 =A0hldev->toc_reg =3D __vxge_hw_device_toc_get(hldev->bar=
0);
> =A0 =A0 =A0 =A0if (hldev->toc_reg =A0=3D=3D NULL) {
> @@ -609,39 +609,31 @@ __vxge_hw_device_reg_addr_get(struct __vxge_hw_=
device *hldev)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0val64 =3D readq(&hldev->toc_reg->toc_common_pointer);
> - =A0 =A0 =A0 hldev->common_reg =3D
> - =A0 =A0 =A0 (struct vxge_hw_common_reg __iomem *)(hldev->bar0 + val=
64);
> + =A0 =A0 =A0 hldev->common_reg =3D hldev->bar0 + val64;
>
> =A0 =A0 =A0 =A0val64 =3D readq(&hldev->toc_reg->toc_mrpcim_pointer);
> - =A0 =A0 =A0 hldev->mrpcim_reg =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct vxge_hw_mrpcim_reg __iomem *)(h=
ldev->bar0 + val64);
> + =A0 =A0 =A0 hldev->mrpcim_reg =3D hldev->bar0 + val64;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < VXGE_HW_TITAN_SRPCIM_REG_SPACES; i++=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&hldev->toc_reg->toc_s=
rpcim_pointer[i]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->srpcim_reg[i] =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct vxge_hw_srpcim_=
reg __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (hldev-=
>bar0 + val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->srpcim_reg[i] =3D hldev->bar0 + =
val64;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < VXGE_HW_TITAN_VPMGMT_REG_SPACES; i++=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&hldev->toc_reg->toc_v=
pmgmt_pointer[i]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->vpmgmt_reg[i] =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct vxge_hw_vpmgmt_reg __iomem *)(h=
ldev->bar0 + val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->vpmgmt_reg[i] =3D hldev->bar0 + =
val64;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < VXGE_HW_TITAN_VPATH_REG_SPACES; i++)=
 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&hldev->toc_reg->toc_v=
path_pointer[i]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->vpath_reg[i] =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct vxge_hw_vpath_r=
eg __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (hldev-=
>bar0 + val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->vpath_reg[i] =3D hldev->bar0 + v=
al64;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0val64 =3D readq(&hldev->toc_reg->toc_kdfc);
>
> =A0 =A0 =A0 =A0switch (VXGE_HW_TOC_GET_KDFC_INITIAL_BIR(val64)) {
> =A0 =A0 =A0 =A0case 0:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->kdfc =3D (u8 __iomem *)(hldev->b=
ar0 +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VXGE_HW_TOC_GET_KDFC_IN=
ITIAL_OFFSET(val64));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hldev->kdfc =3D hldev->bar0 + VXGE_HW_T=
OC_GET_KDFC_INITIAL_OFFSET(val64) ;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -1024,7 +1016,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0val64 =3D readq(&toc->toc_common_pointer);
> - =A0 =A0 =A0 common_reg =3D (struct vxge_hw_common_reg __iomem *)(ba=
r0 + val64);
> + =A0 =A0 =A0 common_reg =3D bar0 + val64;
>
> =A0 =A0 =A0 =A0status =3D __vxge_hw_device_vpath_reset_in_prog_check(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u64 __iomem *)&common_reg->vpath_rst_=
in_prog);
> @@ -1044,8 +1036,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&toc->toc_vpmgmt_point=
er[i]);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vpmgmt_reg =3D (struct vxge_hw_vpmgmt_r=
eg __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (bar0 +=
 val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vpmgmt_reg =3D bar0 + val64;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hw_info->func_id =3D __vxge_hw_vpath_f=
unc_id_get(vpmgmt_reg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (__vxge_hw_device_access_rights_get=
(hw_info->host_type,
> @@ -1054,8 +1045,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&toc->=
toc_mrpcim_pointer);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mrpcim_reg =3D (struct =
vxge_hw_mrpcim_reg __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 (bar0 + val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mrpcim_reg =3D bar0 + v=
al64;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0writeq(0, &mrpcim_reg-=
>xgmac_gen_fw_memo_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wmb();
> @@ -1064,8 +1054,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&toc->toc_vpath_pointe=
r[i]);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_init(&vpath.lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vpath.vp_reg =3D (struct vxge_hw_vpath_=
reg __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(bar0 + =
val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vpath.vp_reg =3D bar0 + val64;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vpath.vp_open =3D VXGE_HW_VP_NOT_OPEN;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D __vxge_hw_vpath_pci_func_mo=
de_get(&vpath, hw_info);
> @@ -1088,8 +1077,7 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val64 =3D readq(&toc->toc_vpath_pointe=
r[i]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vpath.vp_reg =3D (struct vxge_hw_vpath_=
reg __iomem *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(bar0 + =
val64);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vpath.vp_reg =3D bar0 + val64;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vpath.vp_open =3D VXGE_HW_VP_NOT_OPEN;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D =A0__vxge_hw_vpath_addr_get=
(&vpath,
> @@ -2140,8 +2128,7 @@ __vxge_hw_ring_mempool_item_alloc(struct vxge_h=
w_mempool *mempoolh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0memblock_index, item,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0&memblock_item_idx);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxdp =3D (struct vxge_hw_ring_rxd_1 *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ring->c=
hannel.reserve_arr[reserve_index];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxdp =3D ring->channel.reserve_arr[rese=
rve_index];
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uld_priv =3D ((u8 *)rxdblock_priv + ri=
ng->rxd_priv_size * i);
>
> @@ -4880,8 +4867,7 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hld=
ev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto vpath_open_exit8;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 vpath->hw_stats =3D (struct vxge_hw_vpath_stats_hw_info=
 *)vpath->
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats_block->memblock;
> + =A0 =A0 =A0 vpath->hw_stats =3D vpath->stats_block->memblock;
> =A0 =A0 =A0 =A0memset(vpath->hw_stats, 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(struct vxge_hw_vpath_stats_hw_i=
nfo));
>
> diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-=
traffic.c
> index f935170..ad64ce0 100644
> --- a/drivers/net/vxge/vxge-traffic.c
> +++ b/drivers/net/vxge/vxge-traffic.c
> @@ -1309,7 +1309,7 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_compl=
eted(
>
> =A0 =A0 =A0 =A0vxge_hw_channel_dtr_try_complete(channel, rxdh);
>
> - =A0 =A0 =A0 rxdp =3D (struct vxge_hw_ring_rxd_1 *)*rxdh;
> + =A0 =A0 =A0 rxdp =3D *rxdh;
> =A0 =A0 =A0 =A0if (rxdp =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D VXGE_HW_INF_NO_MORE_COMPLET=
ED_DESCRIPTORS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto exit;
> @@ -1565,7 +1565,7 @@ void vxge_hw_fifo_txdl_post(struct __vxge_hw_fi=
fo *fifo, void *txdlh)
> =A0 =A0 =A0 =A0channel =3D &fifo->channel;
>
> =A0 =A0 =A0 =A0txdl_priv =3D __vxge_hw_fifo_txdl_priv(fifo, txdlh);
> - =A0 =A0 =A0 txdp_first =3D (struct vxge_hw_fifo_txd *)txdlh;
> + =A0 =A0 =A0 txdp_first =3D txdlh;
>
> =A0 =A0 =A0 =A0txdp_last =3D (struct vxge_hw_fifo_txd *)txdlh =A0+ =A0=
(txdl_priv->frags - 1);
> =A0 =A0 =A0 =A0txdp_last->control_0 |=3D
> @@ -1631,7 +1631,7 @@ enum vxge_hw_status vxge_hw_fifo_txdl_next_comp=
leted(
>
> =A0 =A0 =A0 =A0vxge_hw_channel_dtr_try_complete(channel, txdlh);
>
> - =A0 =A0 =A0 txdp =3D (struct vxge_hw_fifo_txd *)*txdlh;
> + =A0 =A0 =A0 txdp =3D *txdlh;
> =A0 =A0 =A0 =A0if (txdp =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D VXGE_HW_INF_NO_MORE_COMPLET=
ED_DESCRIPTORS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto exit;

Thanks so much!

Acked-by: Jon Mason <jdmason@kudzu.us>

> diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.=
c
> index 1c65d1c..850fc84 100644
> --- a/drivers/net/wan/pc300_tty.c
> +++ b/drivers/net/wan/pc300_tty.c
> @@ -755,7 +755,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
>
> =A0 =A0 =A0 =A0dsr_rx =3D cpc_readb(card->hw.scabase + DSR_RX(ch));
>
> - =A0 =A0 =A0 cpc_tty =3D (st_cpc_tty_area *)pc300dev->cpc_tty;
> + =A0 =A0 =A0 cpc_tty =3D pc300dev->cpc_tty;
>
> =A0 =A0 =A0 =A0while (1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_len =3D 0;
> diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emacl=
ite.c
> index 9cb4cdc..bbb8c65 100644
> --- a/drivers/net/xilinx_emaclite.c
> +++ b/drivers/net/xilinx_emaclite.c
> @@ -252,11 +252,11 @@ static void xemaclite_aligned_write(void *src_p=
tr, u32 *dest_ptr,
> =A0 =A0 =A0 =A0u16 *from_u16_ptr, *to_u16_ptr;
>
> =A0 =A0 =A0 =A0to_u32_ptr =3D dest_ptr;
> - =A0 =A0 =A0 from_u16_ptr =3D (u16 *) src_ptr;
> + =A0 =A0 =A0 from_u16_ptr =3D src_ptr;
> =A0 =A0 =A0 =A0align_buffer =3D 0;
>
> =A0 =A0 =A0 =A0for (; length > 3; length -=3D 4) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 to_u16_ptr =3D (u16 *) ((void *) &align=
_buffer);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 to_u16_ptr =3D (u16 *)&align_buffer;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*to_u16_ptr++ =3D *from_u16_ptr++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*to_u16_ptr++ =3D *from_u16_ptr++;
>
> diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
> index ec47e22..3e5ac60 100644
> --- a/drivers/net/yellowfin.c
> +++ b/drivers/net/yellowfin.c
> @@ -442,19 +442,19 @@ static int __devinit yellowfin_init_one(struct =
pci_dev *pdev,
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, TX_TOTAL_SIZ=
E, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_cleardev;
> - =A0 =A0 =A0 np->tx_ring =3D (struct yellowfin_desc *)ring_space;
> + =A0 =A0 =A0 np->tx_ring =3D ring_space;
> =A0 =A0 =A0 =A0np->tx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, RX_TOTAL_SIZ=
E, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_unmap_tx;
> - =A0 =A0 =A0 np->rx_ring =3D (struct yellowfin_desc *)ring_space;
> + =A0 =A0 =A0 np->rx_ring =3D ring_space;
> =A0 =A0 =A0 =A0np->rx_ring_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0ring_space =3D pci_alloc_consistent(pdev, STATUS_TOTAL=
_SIZE, &ring_dma);
> =A0 =A0 =A0 =A0if (!ring_space)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out_unmap_rx;
> - =A0 =A0 =A0 np->tx_status =3D (struct tx_status_words *)ring_space;
> + =A0 =A0 =A0 np->tx_status =3D ring_space;
> =A0 =A0 =A0 =A0np->tx_status_dma =3D ring_dma;
>
> =A0 =A0 =A0 =A0if (dev->mem_start)
> --
> 1.7.6.rc0
>
>
