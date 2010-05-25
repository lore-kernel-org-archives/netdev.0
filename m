From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: pull request: wireless-2.6 2010-05-25
Date: Tue, 25 May 2010 21:23:03 +0200
Message-ID: <AANLkTilMYGSprjMnmRHlZPMvk1KLd1Yeqd_l26yyVRT6@mail.gmail.com>
References: <20100525170401.GE31753@tuxdriver.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:55849 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab0EYTYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 15:24:03 -0400
In-Reply-To: <20100525170401.GE31753@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"[1/2] iwlwifi: fix internal scan race" [1] is in this pull request.
Isn't "[2/2] iwlagn: work around rate scaling reset delay" [2] missing?
IIRC, both fixes were sent as a double-patch.

- Sedat -

[1] https://patchwork.kernel.org/patch/99439/
[2] https://patchwork.kernel.org/patch/99438/

On Tue, May 25, 2010 at 7:04 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> Dave,
>
> Here are a number of fixes intended for 2.6.35. =C2=A0Included are so=
me
> warning fixes from Randy, some smatch-identified fixes from Dan, some
> fixes for using ath9k and IBSS mode, the removal of a PCI ID that was
> optimistically added to ath9k, and a smattering of other driver fixes=
=2E
> This also includes a revert of "ath9k: Group Key fix for VAPs" which
> was reported to cause regressions due to a mac80211 change inside it
> that snuck past us... :-(
>
> Anyway, these are mostly small(ish) and obvious. =C2=A0Please let me =
know
> if there are problems!
>
> Thanks,
>
> John
>
> ---
>
> The following changes since commit acfbe96a3035639619a6533e04d88ed4ef=
9ccb61:
> =C2=A0Randy Dunlap (1):
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sock.h: fix kernel-doc warning
>
> are available in the git repository at:
>
> =C2=A0git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless=
-2.6.git master
>
> Bruno Randolf (1):
> =C2=A0 =C2=A0 =C2=A0ath5k: consistently use rx_bufsize for RX DMA
>
> Dan Carpenter (3):
> =C2=A0 =C2=A0 =C2=A0ath9k_htc: dereferencing before check in hif_usb_=
tx_cb()
> =C2=A0 =C2=A0 =C2=A0ath9k_htc: rare leak in ath9k_hif_usb_alloc_tx_ur=
bs()
> =C2=A0 =C2=A0 =C2=A0iwlwifi: testing the wrong variable in iwl_add_bs=
sid_station()
>
> Felix Fietkau (3):
> =C2=A0 =C2=A0 =C2=A0cfg80211: fix crash in cfg80211_set_freq()
> =C2=A0 =C2=A0 =C2=A0ath9k: change beacon allocation to prefer the fir=
st beacon slot
> =C2=A0 =C2=A0 =C2=A0ath9k: remove VEOL support for ad-hoc
>
> Gertjan van Wingerde (2):
> =C2=A0 =C2=A0 =C2=A0rt2x00: Fix failed SLEEP->AWAKE and AWAKE->SLEEP =
transitions.
> =C2=A0 =C2=A0 =C2=A0rt2x00: Fix rt2800usb TX descriptor writing.
>
> Helmut Schaa (1):
> =C2=A0 =C2=A0 =C2=A0rt2x00: don't use to_pci_dev in rt2x00pci_uniniti=
alize
>
> Johannes Berg (1):
> =C2=A0 =C2=A0 =C2=A0cfg80211: add missing braces
>
> John W. Linville (1):
> =C2=A0 =C2=A0 =C2=A0Revert "ath9k: Group Key fix for VAPs"
>
> Jussi Kivilinna (1):
> =C2=A0 =C2=A0 =C2=A0rndis_wlan: replace wireless_send_event with cfg8=
0211_disconnected
>
> Juuso Oikarinen (1):
> =C2=A0 =C2=A0 =C2=A0wl1271: Fix RX data path frame lengths
>
> Luis R. Rodriguez (1):
> =C2=A0 =C2=A0 =C2=A0ath9k: remove AR9003 from PCI IDs for now
>
> Randy Dunlap (2):
> =C2=A0 =C2=A0 =C2=A0wireless: fix mac80211.h kernel-doc warnings
> =C2=A0 =C2=A0 =C2=A0wireless: fix sta_info.h kernel-doc warnings
>
> Reinette Chatre (1):
> =C2=A0 =C2=A0 =C2=A0iwlwifi: fix internal scan race
>
> Sujith (1):
> =C2=A0 =C2=A0 =C2=A0cfg80211: Fix signal_type comparison
>
> Tejun Heo (1):
> =C2=A0 =C2=A0 =C2=A0wireless: update gfp/slab.h includes
>
> Vasanthakumar Thiagarajan (1):
> =C2=A0 =C2=A0 =C2=A0ath9k: Fix rx of mcast/bcast frames in PS mode wi=
th auto sleep
>
> =C2=A0drivers/net/wireless/ath/ath5k/base.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A07 ++-
> =C2=A0drivers/net/wireless/ath/ath9k/beacon.c =C2=A0 =C2=A0| =C2=A0 7=
5 +++++-----------------------
> =C2=A0drivers/net/wireless/ath/ath9k/hif_usb.c =C2=A0 | =C2=A0 10 +++=
-
> =C2=A0drivers/net/wireless/ath/ath9k/htc.h =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A01 +
> =C2=A0drivers/net/wireless/ath/ath9k/main.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 28 +---------
> =C2=A0drivers/net/wireless/ath/ath9k/pci.c =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A01 -
> =C2=A0drivers/net/wireless/ath/ath9k/recv.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 17 +++++--
> =C2=A0drivers/net/wireless/iwlwifi/iwl-agn-ict.c | =C2=A0 =C2=A01 +
> =C2=A0drivers/net/wireless/iwlwifi/iwl-scan.c =C2=A0 =C2=A0| =C2=A0 2=
1 +++++++-
> =C2=A0drivers/net/wireless/iwlwifi/iwl-sta.c =C2=A0 =C2=A0 | =C2=A0 =C2=
=A02 +-
> =C2=A0drivers/net/wireless/rndis_wlan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 16 ++++--
> =C2=A0drivers/net/wireless/rt2x00/rt2400pci.c =C2=A0 =C2=A0| =C2=A0 =C2=
=A09 ++--
> =C2=A0drivers/net/wireless/rt2x00/rt2500pci.c =C2=A0 =C2=A0| =C2=A0 =C2=
=A09 ++--
> =C2=A0drivers/net/wireless/rt2x00/rt2800usb.c =C2=A0 =C2=A0| =C2=A0 =C2=
=A02 +-
> =C2=A0drivers/net/wireless/rt2x00/rt2x00pci.c =C2=A0 =C2=A0| =C2=A0 =C2=
=A02 +-
> =C2=A0drivers/net/wireless/rt2x00/rt61pci.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A07 ++-
> =C2=A0drivers/net/wireless/rt2x00/rt73usb.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A07 ++-
> =C2=A0drivers/net/wireless/wl12xx/wl1271_rx.c =C2=A0 =C2=A0| =C2=A0 =C2=
=A02 +
> =C2=A0include/net/mac80211.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 +-
> =C2=A0net/mac80211/key.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A01 -
> =C2=A0net/mac80211/sta_info.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0net/wireless/chan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0net/wireless/nl80211.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A06 ++-
> =C2=A0net/wireless/scan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 +-
> =C2=A024 files changed, 104 insertions(+), 132 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wire=
less/ath/ath5k/base.c
> index 5f04cf3..cc6d41d 100644
> --- a/drivers/net/wireless/ath/ath5k/base.c
> +++ b/drivers/net/wireless/ath/ath5k/base.c
> @@ -1214,6 +1214,7 @@ ath5k_rxbuf_setup(struct ath5k_softc *sc, struc=
t ath5k_buf *bf)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ath5k_hw *ah =3D sc->ah;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb =3D bf->skb;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ath5k_desc *ds;
> + =C2=A0 =C2=A0 =C2=A0 int ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!skb) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb =3D ath5k_=
rx_skb_alloc(sc, &bf->skbaddr);
> @@ -1240,9 +1241,9 @@ ath5k_rxbuf_setup(struct ath5k_softc *sc, struc=
t ath5k_buf *bf)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ds =3D bf->desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ds->ds_link =3D bf->daddr; =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* link to self */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ds->ds_data =3D bf->skbaddr;
> - =C2=A0 =C2=A0 =C2=A0 ah->ah_setup_rx_desc(ah, ds,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_tailroom(skb),=
 =C2=A0 =C2=A0 =C2=A0/* buffer size */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D ah->ah_setup_rx_desc(ah, ds, ah->commo=
n.rx_bufsize, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (ret)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->rxlink !=3D NULL)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*sc->rxlink =3D=
 bf->daddr;
> diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wi=
reless/ath/ath9k/beacon.c
> index c8a4558..f43d85a 100644
> --- a/drivers/net/wireless/ath/ath9k/beacon.c
> +++ b/drivers/net/wireless/ath/ath9k/beacon.c
> @@ -76,22 +76,13 @@ static void ath_beacon_setup(struct ath_softc *sc=
, struct ath_vif *avp,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ds =3D bf->bf_desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0flags =3D ATH9K_TXDESC_NOACK;
>
> - =C2=A0 =C2=A0 =C2=A0 if (((sc->sc_ah->opmode =3D=3D NL80211_IFTYPE_=
ADHOC) ||
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(sc->sc_ah->opmode =3D=3D =
NL80211_IFTYPE_MESH_POINT)) &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (ah->caps.hw_caps & ATH9K_HW_CAP=
_VEOL)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ds->ds_link =3D bf=
->bf_daddr; /* self-linked */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 flags |=3D ATH9K_T=
XDESC_VEOL;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Let hardware ha=
ndle antenna switching. */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 antenna =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 } else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ds->ds_link =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Switch ant=
enna every beacon.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Should onl=
y switch every beacon period, not for every SWBA
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX assume=
s two antennae
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 antenna =3D ((sc->=
beacon.ast_be_xmit / sc->nbcnvifs) & 1 ? 2 : 1);
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 ds->ds_link =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Switch antenna every beacon.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Should only switch every beacon period=
, not for every SWBA
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX assumes two antennae
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 antenna =3D ((sc->beacon.ast_be_xmit / sc->nbc=
nvifs) & 1 ? 2 : 1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sband =3D &sc->sbands[common->hw->conf.cha=
nnel->band];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rate =3D sband->bitrates[rateidx].hw_value=
;
> @@ -215,36 +206,6 @@ static struct ath_buf *ath_beacon_generate(struc=
t ieee80211_hw *hw,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return bf;
> =C2=A0}
>
> -/*
> - * Startup beacon transmission for adhoc mode when they are sent ent=
irely
> - * by the hardware using the self-linked descriptor + veol trick.
> -*/
> -static void ath_beacon_start_adhoc(struct ath_softc *sc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ieee80211_vif *=
vif)
> -{
> - =C2=A0 =C2=A0 =C2=A0 struct ath_hw *ah =3D sc->sc_ah;
> - =C2=A0 =C2=A0 =C2=A0 struct ath_common *common =3D ath9k_hw_common(=
ah);
> - =C2=A0 =C2=A0 =C2=A0 struct ath_buf *bf;
> - =C2=A0 =C2=A0 =C2=A0 struct ath_vif *avp;
> - =C2=A0 =C2=A0 =C2=A0 struct sk_buff *skb;
> -
> - =C2=A0 =C2=A0 =C2=A0 avp =3D (void *)vif->drv_priv;
> -
> - =C2=A0 =C2=A0 =C2=A0 if (avp->av_bcbuf =3D=3D NULL)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> -
> - =C2=A0 =C2=A0 =C2=A0 bf =3D avp->av_bcbuf;
> - =C2=A0 =C2=A0 =C2=A0 skb =3D bf->bf_mpdu;
> -
> - =C2=A0 =C2=A0 =C2=A0 ath_beacon_setup(sc, avp, bf, 0);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* NB: caller is known to have already stopped=
 tx dma */
> - =C2=A0 =C2=A0 =C2=A0 ath9k_hw_puttxbuf(ah, sc->beacon.beaconq, bf->=
bf_daddr);
> - =C2=A0 =C2=A0 =C2=A0 ath9k_hw_txstart(ah, sc->beacon.beaconq);
> - =C2=A0 =C2=A0 =C2=A0 ath_print(common, ATH_DBG_BEACON, "TXDP%u =3D =
%llx (%p)\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->beacon.=
beaconq, ito64(bf->bf_daddr), bf->bf_desc);
> -}
> -
> =C2=A0int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_v=
if *vif)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ath_softc *sc =3D aphy->sc;
> @@ -265,7 +226,8 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, stru=
ct ieee80211_vif *vif)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&avp-=
>av_bcbuf->list);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->sc_ah-=
>opmode =3D=3D NL80211_IFTYPE_AP ||
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !(sc=
->sc_ah->caps.hw_caps & ATH9K_HW_CAP_VEOL)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->=
sc_ah->opmode =3D=3D NL80211_IFTYPE_ADHOC ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->=
sc_ah->opmode =3D=3D NL80211_IFTYPE_MESH_POINT) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0int slot;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 * Assign the vif to a beacon xmit slot. As
> @@ -274,17 +236,11 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, st=
ruct ieee80211_vif *vif)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0avp->av_bslot =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0for (slot =3D 0; slot < ATH_BCBUF; slot++)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->beacon.bslot[slot] =3D=
=3D NULL) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*=
 XXX hack, space out slots to better
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*=
 deal with misses
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*=
/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (slo=
t+1 < ATH_BCBUF &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 sc->beacon.bslot[slot+1] =3D=3D NULL) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 avp->av_bslot =3D slot+1;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 break;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0a=
vp->av_bslot =3D slot;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/=
* NB: keep looking for a double slot */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (slo=
t =3D=3D 0 || !sc->beacon.bslot[slot-1])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0BUG_ON(sc->beacon.bslot[avp->av_bslot] !=3D NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0sc->beacon.bslot[avp->av_bslot] =3D vif;
> @@ -721,8 +677,7 @@ static void ath_beacon_config_adhoc(struct ath_so=
ftc *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * self-linked tx descriptor and let the h=
ardware deal with things.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0intval |=3D ATH9K_BEACON_ENA;
> - =C2=A0 =C2=A0 =C2=A0 if (!(ah->caps.hw_caps & ATH9K_HW_CAP_VEOL))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ah->imask |=3D ATH=
9K_INT_SWBA;
> + =C2=A0 =C2=A0 =C2=A0 ah->imask |=3D ATH9K_INT_SWBA;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ath_beaconq_config(sc);
>
> @@ -732,10 +687,6 @@ static void ath_beacon_config_adhoc(struct ath_s=
oftc *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ath9k_beacon_init(sc, nexttbtt, intval);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->beacon.bmisscnt =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ath9k_hw_set_interrupts(ah, ah->imask);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* FIXME: Handle properly when vif is NULL */
> - =C2=A0 =C2=A0 =C2=A0 if (vif && ah->caps.hw_caps & ATH9K_HW_CAP_VEO=
L)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ath_beacon_start_a=
dhoc(sc, vif);
> =C2=A0}
>
> =C2=A0void ath_beacon_config(struct ath_softc *sc, struct ieee80211_v=
if *vif)
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/w=
ireless/ath/ath9k/hif_usb.c
> index 46dc41a..77b3591 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.c
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
> @@ -107,12 +107,14 @@ static inline void ath9k_skb_queue_purge(struct=
 hif_device_usb *hif_dev,
> =C2=A0static void hif_usb_tx_cb(struct urb *urb)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_buf *tx_buf =3D (struct tx_buf *=
) urb->context;
> - =C2=A0 =C2=A0 =C2=A0 struct hif_device_usb *hif_dev =3D tx_buf->hif=
_dev;
> + =C2=A0 =C2=A0 =C2=A0 struct hif_device_usb *hif_dev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb;
>
> - =C2=A0 =C2=A0 =C2=A0 if (!hif_dev || !tx_buf)
> + =C2=A0 =C2=A0 =C2=A0 if (!tx_buf || !tx_buf->hif_dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>
> + =C2=A0 =C2=A0 =C2=A0 hif_dev =3D tx_buf->hif_dev;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (urb->status) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case 0:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> @@ -607,6 +609,10 @@ static int ath9k_hif_usb_alloc_tx_urbs(struct hi=
f_device_usb *hif_dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0err:
> + =C2=A0 =C2=A0 =C2=A0 if (tx_buf) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(tx_buf->buf)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(tx_buf);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ath9k_hif_usb_dealloc_tx_urbs(hif_dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;
> =C2=A0}
> diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wirel=
ess/ath/ath9k/htc.h
> index ad556aa..c251603 100644
> --- a/drivers/net/wireless/ath/ath9k/htc.h
> +++ b/drivers/net/wireless/ath/ath9k/htc.h
> @@ -23,6 +23,7 @@
> =C2=A0#include <linux/skbuff.h>
> =C2=A0#include <linux/netdevice.h>
> =C2=A0#include <linux/leds.h>
> +#include <linux/slab.h>
> =C2=A0#include <net/mac80211.h>
>
> =C2=A0#include "common.h"
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wire=
less/ath/ath9k/main.c
> index 893b552..abfa049 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -752,7 +752,6 @@ static int ath_key_config(struct ath_common *comm=
on,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ath_hw *ah =3D common->ah;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ath9k_keyval hk;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const u8 *mac =3D NULL;
> - =C2=A0 =C2=A0 =C2=A0 u8 gmac[ETH_ALEN];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int idx;
>
> @@ -776,30 +775,9 @@ static int ath_key_config(struct ath_common *com=
mon,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(hk.kv_val, key->key, key->keylen);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(key->flags & IEEE80211_KEY_FLAG_PAIR=
WISE)) {
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (key->ap_addr) =
{
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* Group keys on hardware that supports multicast frame
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* key search use a mac that is the sender's address with
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* the high bit set instead of the app-specified address.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 memcpy(gmac, key->ap_addr, ETH_ALEN);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 gmac[0] |=3D 0x80;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mac =3D gmac;
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (key->alg =3D=3D ALG_TKIP)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 idx =3D ath_reserve_key_cache_slot_=
tkip(common);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 idx =3D ath_reserve_key_cache_slot(=
common);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (idx < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mac =3D NULL; /* no free key cache =
entries */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mac) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* For now, use the default keys for broadcast keys. This may
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* need to change with virtual interfaces. */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 idx =3D key->keyidx;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* For now, use th=
e default keys for broadcast keys. This may
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* need to ch=
ange with virtual interfaces. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 idx =3D key->keyid=
x;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (key->keyidx) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (WARN_ON(!s=
ta))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return -EOPNOTSUPP;
> diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wirel=
ess/ath/ath9k/pci.c
> index 257b10b..1ec836c 100644
> --- a/drivers/net/wireless/ath/ath9k/pci.c
> +++ b/drivers/net/wireless/ath/ath9k/pci.c
> @@ -28,7 +28,6 @@ static DEFINE_PCI_DEVICE_TABLE(ath_pci_id_table) =3D=
 {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ PCI_VDEVICE(ATHEROS, 0x002C) }, /* PCI-E=
 802.11n bonded out */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ PCI_VDEVICE(ATHEROS, 0x002D) }, /* PCI =C2=
=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ PCI_VDEVICE(ATHEROS, 0x002E) }, /* PCI-E=
 */
> - =C2=A0 =C2=A0 =C2=A0 { PCI_VDEVICE(ATHEROS, 0x0030) }, /* PCI-E =C2=
=A0AR9300 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ 0 }
> =C2=A0};
>
> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wire=
less/ath/ath9k/recv.c
> index ba13913..ca6065b 100644
> --- a/drivers/net/wireless/ath/ath9k/recv.c
> +++ b/drivers/net/wireless/ath/ath9k/recv.c
> @@ -19,6 +19,12 @@
>
> =C2=A0#define SKB_CB_ATHBUF(__skb) =C2=A0 (*((struct ath_buf **)__skb=
->cb))
>
> +static inline bool ath9k_check_auto_sleep(struct ath_softc *sc)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return sc->ps_enabled &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(sc->sc_ah->caps.hw=
_caps & ATH9K_HW_CAP_AUTOSLEEP);
> +}
> +
> =C2=A0static struct ieee80211_hw * ath_get_virt_hw(struct ath_softc *=
sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 struct ieee80211_hdr *hdr)
> =C2=A0{
> @@ -616,8 +622,8 @@ static void ath_rx_ps(struct ath_softc *sc, struc=
t sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0hdr =3D (struct ieee80211_hdr *)skb->data;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Process Beacon and CAB receive in PS st=
ate */
> - =C2=A0 =C2=A0 =C2=A0 if ((sc->ps_flags & PS_WAIT_FOR_BEACON) &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ieee80211_is_beacon(hdr->frame_c=
ontrol))
> + =C2=A0 =C2=A0 =C2=A0 if (((sc->ps_flags & PS_WAIT_FOR_BEACON) || at=
h9k_check_auto_sleep(sc))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 && ieee80211_is_beacon(hdr->fram=
e_control))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ath_rx_ps_beac=
on(sc, skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else if ((sc->ps_flags & PS_WAIT_FOR_CAB) =
&&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (ieee80211_is=
_data(hdr->frame_control) ||
> @@ -932,9 +938,10 @@ int ath_rx_tasklet(struct ath_softc *sc, int flu=
sh, bool hp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0sc->rx.rxotherant =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(sc->p=
s_flags & (PS_WAIT_FOR_BEACON |
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0PS_WAIT_FOR_CAB |
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0PS_WAIT_FOR_PSPOLL_DATA)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(ath9k=
_check_auto_sleep(sc) ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0(sc->ps_flags & (PS_WAIT_FOR_BEACON |
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 PS_WAIT_FOR_CAB |
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 PS_WAIT_FOR_PSPOLL_DATA))))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0ath_rx_ps(sc, skb);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ath_rx_send_to=
_mac80211(hw, sc, skb, rxs);
> diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-ict.c b/drivers/net=
/wireless/iwlwifi/iwl-agn-ict.c
> index a273e37..c92b2c0 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
> @@ -30,6 +30,7 @@
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/etherdevice.h>
> =C2=A0#include <linux/sched.h>
> +#include <linux/gfp.h>
> =C2=A0#include <net/mac80211.h>
>
> =C2=A0#include "iwl-dev.h"
> diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wi=
reless/iwlwifi/iwl-scan.c
> index 107e173..5d3f51f 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-scan.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
> @@ -376,6 +376,11 @@ void iwl_bg_start_internal_scan(struct work_stru=
ct *work)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&priv->mutex);
>
> + =C2=A0 =C2=A0 =C2=A0 if (priv->is_internal_short_scan =3D=3D true) =
{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IWL_DEBUG_SCAN(pri=
v, "Internal scan already in progress\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!iwl_is_ready_rf(priv)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IWL_DEBUG_SCAN=
(priv, "not ready or exit pending\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto unlock;
> @@ -497,17 +502,27 @@ void iwl_bg_scan_completed(struct work_struct *=
work)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct iwl_priv *priv =3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0container_of(work, struct iw=
l_priv, scan_completed);
> + =C2=A0 =C2=A0 =C2=A0 bool internal =3D false;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0IWL_DEBUG_SCAN(priv, "SCAN complete scan\n=
");
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cancel_delayed_work(&priv->scan_check);
>
> - =C2=A0 =C2=A0 =C2=A0 if (!priv->is_internal_short_scan)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ieee80211_scan_com=
pleted(priv->hw, false);
> - =C2=A0 =C2=A0 =C2=A0 else {
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&priv->mutex);
> + =C2=A0 =C2=A0 =C2=A0 if (priv->is_internal_short_scan) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0priv->is_inter=
nal_short_scan =3D false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IWL_DEBUG_SCAN=
(priv, "internal short scan completed\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 internal =3D true;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&priv->mutex);
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Do not hold mutex here since this will=
 cause mac80211 to call
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* into driver again into functions that =
will attempt to take
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* mutex.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (!internal)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ieee80211_scan_com=
pleted(priv->hw, false);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (test_bit(STATUS_EXIT_PENDING, &priv->s=
tatus))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wir=
eless/iwlwifi/iwl-sta.c
> index 85ed235..83a2636 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-sta.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
> @@ -431,7 +431,7 @@ int iwl_add_bssid_station(struct iwl_priv *priv, =
const u8 *addr, bool init_rs,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct iwl_link_quality_cmd *link_cmd;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> - =C2=A0 =C2=A0 =C2=A0 if (*sta_id_r)
> + =C2=A0 =C2=A0 =C2=A0 if (sta_id_r)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*sta_id_r =3D =
IWL_INVALID_STATION;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D iwl_add_station_common(priv, addr,=
 0, NULL, &sta_id);
> diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless=
/rndis_wlan.c
> index 2d28908..4bd61ee 100644
> --- a/drivers/net/wireless/rndis_wlan.c
> +++ b/drivers/net/wireless/rndis_wlan.c
> @@ -2572,14 +2572,18 @@ static void rndis_wlan_do_link_up_work(struct=
 usbnet *usbdev)
>
> =C2=A0static void rndis_wlan_do_link_down_work(struct usbnet *usbdev)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 union iwreq_data evt;
> + =C2=A0 =C2=A0 =C2=A0 struct rndis_wlan_private *priv =3D get_rndis_=
wlan_priv(usbdev);
>
> - =C2=A0 =C2=A0 =C2=A0 netif_carrier_off(usbdev->net);
> + =C2=A0 =C2=A0 =C2=A0 if (priv->connected) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 priv->connected =3D=
 false;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(priv->bssid=
, 0, ETH_ALEN);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 deauthenticate(usb=
dev);
>
> - =C2=A0 =C2=A0 =C2=A0 evt.data.flags =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 evt.data.length =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 memset(evt.ap_addr.sa_data, 0, ETH_ALEN);
> - =C2=A0 =C2=A0 =C2=A0 wireless_send_event(usbdev->net, SIOCGIWAP, &e=
vt, NULL);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cfg80211_disconnec=
ted(usbdev->net, 0, NULL, 0, GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 netif_carrier_off(usbdev->net);
> =C2=A0}
>
> =C2=A0static void rndis_wlan_worker(struct work_struct *work)
> diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wi=
reless/rt2x00/rt2400pci.c
> index 4ba7b03..ad2c98a 100644
> --- a/drivers/net/wireless/rt2x00/rt2400pci.c
> +++ b/drivers/net/wireless/rt2x00/rt2400pci.c
> @@ -926,7 +926,7 @@ static void rt2400pci_disable_radio(struct rt2x00=
_dev *rt2x00dev)
> =C2=A0static int rt2400pci_set_state(struct rt2x00_dev *rt2x00dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum dev_state state)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 u32 reg;
> + =C2=A0 =C2=A0 =C2=A0 u32 reg, reg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char put_to_sleep;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char bbp_state;
> @@ -947,11 +947,12 @@ static int rt2400pci_set_state(struct rt2x00_de=
v *rt2x00dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * device has entered the correct state.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < REGISTER_BUSY_COUNT; i++=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_read(rt2x00dev, PWRCSR1, &reg);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bbp_state =3D rt2x=
00_get_field32(reg, PWRCSR1_BBP_CURR_STATE);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rf_state =3D rt2x0=
0_get_field32(reg, PWRCSR1_RF_CURR_STATE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_read(rt2x00dev, PWRCSR1, &reg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bbp_state =3D rt2x=
00_get_field32(reg2, PWRCSR1_BBP_CURR_STATE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rf_state =3D rt2x0=
0_get_field32(reg2, PWRCSR1_RF_CURR_STATE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (bbp_state =
=3D=3D state && rf_state =3D=3D state)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_write(rt2x00dev, PWRCSR1, reg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0msleep(10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wi=
reless/rt2x00/rt2500pci.c
> index 89d132d..41da3d2 100644
> --- a/drivers/net/wireless/rt2x00/rt2500pci.c
> +++ b/drivers/net/wireless/rt2x00/rt2500pci.c
> @@ -1084,7 +1084,7 @@ static void rt2500pci_disable_radio(struct rt2x=
00_dev *rt2x00dev)
> =C2=A0static int rt2500pci_set_state(struct rt2x00_dev *rt2x00dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum dev_state state)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 u32 reg;
> + =C2=A0 =C2=A0 =C2=A0 u32 reg, reg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char put_to_sleep;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char bbp_state;
> @@ -1105,11 +1105,12 @@ static int rt2500pci_set_state(struct rt2x00_=
dev *rt2x00dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * device has entered the correct state.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < REGISTER_BUSY_COUNT; i++=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_read(rt2x00dev, PWRCSR1, &reg);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bbp_state =3D rt2x=
00_get_field32(reg, PWRCSR1_BBP_CURR_STATE);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rf_state =3D rt2x0=
0_get_field32(reg, PWRCSR1_RF_CURR_STATE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_read(rt2x00dev, PWRCSR1, &reg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bbp_state =3D rt2x=
00_get_field32(reg2, PWRCSR1_BBP_CURR_STATE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rf_state =3D rt2x0=
0_get_field32(reg2, PWRCSR1_RF_CURR_STATE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (bbp_state =
=3D=3D state && rf_state =3D=3D state)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_write(rt2x00dev, PWRCSR1, reg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0msleep(10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wi=
reless/rt2x00/rt2800usb.c
> index 0f8b84b..6991613 100644
> --- a/drivers/net/wireless/rt2x00/rt2800usb.c
> +++ b/drivers/net/wireless/rt2x00/rt2800usb.c
> @@ -413,7 +413,7 @@ static void rt2800usb_write_tx_desc(struct rt2x00=
_dev *rt2x00dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_desc_read(txi, 0, &word);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_set_field32(&word, TXINFO_W0_USB_DM=
A_TX_PKT_LEN,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0skb->len + TXWI_DESC_SIZE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0skb->len - TXINFO_DESC_SIZE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_set_field32(&word, TXINFO_W0_WIV,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc->flags));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_set_field32(&word, TXINFO_W0_QSEL, =
2);
> diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wi=
reless/rt2x00/rt2x00pci.c
> index a016f7c..f71eee6 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00pci.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
> @@ -206,7 +206,7 @@ void rt2x00pci_uninitialize(struct rt2x00_dev *rt=
2x00dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Free irq line.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 free_irq(to_pci_dev(rt2x00dev->dev)->irq, rt2x=
00dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(rt2x00dev->irq, rt2x00dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Free DMA
> diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wire=
less/rt2x00/rt61pci.c
> index 2e3076f..6a74baf 100644
> --- a/drivers/net/wireless/rt2x00/rt61pci.c
> +++ b/drivers/net/wireless/rt2x00/rt61pci.c
> @@ -1689,7 +1689,7 @@ static void rt61pci_disable_radio(struct rt2x00=
_dev *rt2x00dev)
>
> =C2=A0static int rt61pci_set_state(struct rt2x00_dev *rt2x00dev, enum=
 dev_state state)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 u32 reg;
> + =C2=A0 =C2=A0 =C2=A0 u32 reg, reg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char put_to_sleep;
>
> @@ -1706,10 +1706,11 @@ static int rt61pci_set_state(struct rt2x00_de=
v *rt2x00dev, enum dev_state state)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * device has entered the correct state.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < REGISTER_BUSY_COUNT; i++=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_read(rt2x00dev, MAC_CSR12, &reg);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 state =3D rt2x00_g=
et_field32(reg, MAC_CSR12_BBP_CURRENT_STATE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_read(rt2x00dev, MAC_CSR12, &reg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 state =3D rt2x00_g=
et_field32(reg2, MAC_CSR12_BBP_CURRENT_STATE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (state =3D=3D=
 !put_to_sleep)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00pci_register=
_write(rt2x00dev, MAC_CSR12, reg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0msleep(10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wire=
less/rt2x00/rt73usb.c
> index e35bd19..6e0d82e 100644
> --- a/drivers/net/wireless/rt2x00/rt73usb.c
> +++ b/drivers/net/wireless/rt2x00/rt73usb.c
> @@ -1366,7 +1366,7 @@ static void rt73usb_disable_radio(struct rt2x00=
_dev *rt2x00dev)
>
> =C2=A0static int rt73usb_set_state(struct rt2x00_dev *rt2x00dev, enum=
 dev_state state)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 u32 reg;
> + =C2=A0 =C2=A0 =C2=A0 u32 reg, reg2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0char put_to_sleep;
>
> @@ -1383,10 +1383,11 @@ static int rt73usb_set_state(struct rt2x00_de=
v *rt2x00dev, enum dev_state state)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * device has entered the correct state.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < REGISTER_BUSY_COUNT; i++=
) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00usb_register=
_read(rt2x00dev, MAC_CSR12, &reg);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 state =3D rt2x00_g=
et_field32(reg, MAC_CSR12_BBP_CURRENT_STATE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00usb_register=
_read(rt2x00dev, MAC_CSR12, &reg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 state =3D rt2x00_g=
et_field32(reg2, MAC_CSR12_BBP_CURRENT_STATE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (state =3D=3D=
 !put_to_sleep)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt2x00usb_register=
_write(rt2x00dev, MAC_CSR12, reg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0msleep(10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> diff --git a/drivers/net/wireless/wl12xx/wl1271_rx.c b/drivers/net/wi=
reless/wl12xx/wl1271_rx.c
> index 57f4bfd..b98fb64 100644
> --- a/drivers/net/wireless/wl12xx/wl1271_rx.c
> +++ b/drivers/net/wireless/wl12xx/wl1271_rx.c
> @@ -113,6 +113,8 @@ static void wl1271_rx_handle_data(struct wl1271 *=
wl, u32 length)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wl1271_debug(DEBUG_RX, "rx skb 0x%p: %d B =
%s", skb, skb->len,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 beacon ? "beacon" : "");
>
> + =C2=A0 =C2=A0 =C2=A0 skb_trim(skb, skb->len - desc->pad_len);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(IEEE80211_SKB_RXCB(skb), &rx_status=
, sizeof(rx_status));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ieee80211_rx_ni(wl->hw, skb);
> =C2=A0}
> diff --git a/include/net/mac80211.h b/include/net/mac80211.h
> index 5be900d..de22cbf 100644
> --- a/include/net/mac80211.h
> +++ b/include/net/mac80211.h
> @@ -815,6 +815,7 @@ enum ieee80211_key_flags {
> =C2=A0* =C2=A0 =C2=A0 encrypted in hardware.
> =C2=A0* @alg: The key algorithm.
> =C2=A0* @flags: key flags, see &enum ieee80211_key_flags.
> + * @ap_addr: AP's MAC address
> =C2=A0* @keyidx: the key index (0-3)
> =C2=A0* @keylen: key material length
> =C2=A0* @key: key material. For ALG_TKIP the key is encoded as a 256-=
bit (32 byte)
> @@ -831,7 +832,6 @@ struct ieee80211_key_conf {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 iv_len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 hw_key_idx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 flags;
> - =C2=A0 =C2=A0 =C2=A0 u8 *ap_addr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0s8 keyidx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 keylen;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 key[0];
> @@ -1638,6 +1638,8 @@ enum ieee80211_ampdu_mlme_action {
> =C2=A0* =C2=A0 =C2=A0 Returns a negative error code on failure.
> =C2=A0* =C2=A0 =C2=A0 The callback must be atomic.
> =C2=A0*
> + * @get_survey: Return per-channel survey information
> + *
> =C2=A0* @rfkill_poll: Poll rfkill hardware state. If you need this, y=
ou also
> =C2=A0* =C2=A0 =C2=A0 need to set wiphy->rfkill_poll to %true before =
registration,
> =C2=A0* =C2=A0 =C2=A0 and need to call wiphy_rfkill_set_hw_state() in=
 the callback.
> diff --git a/net/mac80211/key.c b/net/mac80211/key.c
> index 8d4b417..e8f6e3b 100644
> --- a/net/mac80211/key.c
> +++ b/net/mac80211/key.c
> @@ -140,7 +140,6 @@ static void ieee80211_key_enable_hw_accel(struct =
ieee80211_key *key)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ieee802=
11_sub_if_data,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u.ap);
>
> - =C2=A0 =C2=A0 =C2=A0 key->conf.ap_addr =3D sdata->dev->dev_addr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D drv_set_key(key->local, SET_KEY, s=
data, sta, &key->conf);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!ret) {
> diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
> index 48a5e80..df9d455 100644
> --- a/net/mac80211/sta_info.h
> +++ b/net/mac80211/sta_info.h
> @@ -145,7 +145,7 @@ enum plink_state {
> =C2=A0/**
> =C2=A0* struct sta_ampdu_mlme - STA aggregation information.
> =C2=A0*
> - * @tid_state_rx: TID's state in Rx session state machine.
> + * @tid_active_rx: TID's state in Rx session state machine.
> =C2=A0* @tid_rx: aggregation info for Rx per TID
> =C2=A0* @tid_state_tx: TID's state in Tx session state machine.
> =C2=A0* @tid_tx: aggregation info for Tx per TID
> diff --git a/net/wireless/chan.c b/net/wireless/chan.c
> index d92d088..b01a6f6 100644
> --- a/net/wireless/chan.c
> +++ b/net/wireless/chan.c
> @@ -50,7 +50,7 @@ int cfg80211_set_freq(struct cfg80211_registered_de=
vice *rdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ieee80211_channel *chan;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int result;
>
> - =C2=A0 =C2=A0 =C2=A0 if (wdev->iftype =3D=3D NL80211_IFTYPE_MONITOR=
)
> + =C2=A0 =C2=A0 =C2=A0 if (wdev && wdev->iftype =3D=3D NL80211_IFTYPE=
_MONITOR)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wdev =3D NULL;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (wdev) {
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index aaa1aad..db71150 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -4443,9 +4443,10 @@ static int nl80211_remain_on_channel(struct sk=
_buff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (channel_ty=
pe !=3D NL80211_CHAN_NO_HT &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
channel_type !=3D NL80211_CHAN_HT20 &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
channel_type !=3D NL80211_CHAN_HT40PLUS &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 chan=
nel_type !=3D NL80211_CHAN_HT40MINUS)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 chan=
nel_type !=3D NL80211_CHAN_HT40MINUS) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0err =3D -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0freq =3D nla_get_u32(info->attrs[NL80211_A=
TTR_WIPHY_FREQ]);
> @@ -4717,9 +4718,10 @@ static int nl80211_action(struct sk_buff *skb,=
 struct genl_info *info)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (channel_ty=
pe !=3D NL80211_CHAN_NO_HT &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
channel_type !=3D NL80211_CHAN_HT20 &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
channel_type !=3D NL80211_CHAN_HT40PLUS &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 chan=
nel_type !=3D NL80211_CHAN_HT40MINUS)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 chan=
nel_type !=3D NL80211_CHAN_HT40MINUS) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0err =3D -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0freq =3D nla_get_u32(info->attrs[NL80211_A=
TTR_WIPHY_FREQ]);
> diff --git a/net/wireless/scan.c b/net/wireless/scan.c
> index a026c6d..58401d2 100644
> --- a/net/wireless/scan.c
> +++ b/net/wireless/scan.c
> @@ -515,7 +515,7 @@ cfg80211_inform_bss(struct wiphy *wiphy,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0privsz =3D wiphy->bss_priv_size;
>
> - =C2=A0 =C2=A0 =C2=A0 if (WARN_ON(wiphy->signal_type =3D=3D NL80211_=
BSS_SIGNAL_UNSPEC &&
> + =C2=A0 =C2=A0 =C2=A0 if (WARN_ON(wiphy->signal_type =3D=3D CFG80211=
_SIGNAL_TYPE_UNSPEC &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0(signal < 0 || signal > 100)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
> @@ -571,7 +571,7 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u.probe_=
resp.variable);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t privsz =3D wiphy->bss_priv_size;
>
> - =C2=A0 =C2=A0 =C2=A0 if (WARN_ON(wiphy->signal_type =3D=3D NL80211_=
BSS_SIGNAL_UNSPEC &&
> + =C2=A0 =C2=A0 =C2=A0 if (WARN_ON(wiphy->signal_type =3D=3D CFG80211=
_SIGNAL_TYPE_UNSPEC &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
(signal < 0 || signal > 100)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
> --
> John W. Linville =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0Someday the world will need a hero, and you
> linville@tuxdriver.com =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0might be all we have. =C2=A0Be ready.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
