From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-11-10
Date: Mon, 10 Nov 2008 15:45:00 -0500
Message-ID: <20081110204500.GL3546@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44206 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584AbYKJUqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 15:46:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

An overdue passle of patches intended for 2.6.29...

There is a bunch of stuff here, mostly driver updates.  We fix some of
the "=E2=80=98__IEEE80211_CONF_SHORT_SLOT_TIME=E2=80=99 is deprecated" =
warnings,
although unfortunately a couple more remain -- we're working on those
too.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit f400923735ecbb67cbe4a3606c9479f69475=
4f51:
  Thomas Graf (1):
        pkt_sched: Control group classifier

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Bob Copeland (3):
      ath5k: fix keytable type buglet in ath5k_hw_reset_key
      ath5k: enable hardware encryption for WEP
      ath5k: update keycache to support TKIP handling

Chr (1):
      p54: initialize all deprecated fields

Christian Lamparter (4):
      p54: introduce new names for device firmwares
      p54: more definitions form lmac_longbow.h and pda.h
      p54: put broadcast frames into the right queues
      p54: AP & Ad-hoc testing

David Kilroy (1):
      orinoco: Move sources to a subdirectory

Emmanuel Grumbach (2):
      iwlwifi: rename generic iwlagn functions that had a HW specific n=
ame
      iwlwifi: rename double inclusion protection name in iwl-commands.=
h

Holger Schurig (1):
      wireless: fix two bad print_ssid conversions

Ilpo J=C3=A4rvinen (1):
      b43legacy: reindent misleading statement

Ivo van Doorn (5):
      rt2x00: Optimize configuration handling
      rt2x00: Remove ieee80211_bss_conf from rt2x00_intf
      rt2x00: Improve interface_modes initialization
      rt2x00: Release rt2x00 2.2.2
      rt2x00: Remove debugfs CSR access wrappers

Johannes Berg (14):
      wireless: move mesh config length constant
      wireless: fix a few sparse warnings
      ath9k: remove useless NULL initialisers
      iwl3945: remove dead code
      iwlwifi: remove implicit direct scan
      iwlwifi: remove unused essid variable
      b43/legacy: remove SSID code
      adm8211: remove SSID code
      mac80211: remove SSID driver code
      iwl3945: remove bogus comment
      don't use net/ieee80211.h
      wireless: implement basic rate helper function
      b43: implement short slot and basic rate handling
      libertas_tf: fix skb tail pointer

John W. Linville (2):
      p54: eliminate warning for uninitialized variable 'tim_len'
      ath9k: correct warning about unintialized variable 'tid'

Jouni Malinen (7):
      mac80211_hwsim: Debug info for BSS config changes
      nl80211: Add basic rate configuration for AP mode
      mac80211_hwsim: Debug info for TX queue parameters
      nl80211: Add TX queue parameter configuration
      mac80211_hwsim: Make sure beacon_timer gets deleted
      mac80211: Allow AP mode to be enabled
      mac80211_hwsim: Add support for client PS mode

Larry Finger (7):
      rtl8187: Remove large delays
      rtl8187: Remove OFDM delays
      rtl8187: Remove CCK delays
      rtl8187: Remove msleep calls after calls to rtl8225_write
      rtl8187: Remove primitive write delays
      rtl8187: Reduce channel switch delay
      rtl8187: Change TX power settings

Luis R. Rodriguez (4):
      cfg80211: a reg rule is invalid if freq diff is 0
      cfg80211: Add regulatory domain intersection capability
      cfg80211: make use of reg macros on REG_RULE
      cfg80211: Add kdoc for struct regulatory_request

Mohamed Abbas (1):
      iwlwifi: do not call statistics from rfkill

Nick Kossifidis (1):
      ath5k: Update PCU code

Pavel Roskin (1):
      p54: don't report known but unhandled EEPROM codes as unknown

Sujith (16):
      ath9k: Node cleanup
      ath9k: Simplify node attach/detach routines
      ath9k: Revamp transmit control block
      ath9k: Remove SM Power Save as it is not supported now
      ath9k: Ensure ath_node is not NULL when updating tx chainmask
      ath9k: Use bitfields to store tid's state in a single variable
      ath9k: Revamp VAP management
      ath9k: Refactor hw.c
      ath9k: Remove unused function ath_get_currentCountry()
      ath9k: Streamline attach/detach
      ath9k: Remove unnecessary TSF reset
      ath9k: Enable interrupts at the proper place
      ath9k: Remove ath_tx_aggr_resp()
      ath9k: Clear HT info on starting the driver
      ath9k: Remove internal RX A-MPDU processing
      mac80211: Add a new event in ieee80211_ampdu_mlme_action

Tomas Winkler (1):
      mac80211: fix basic rates setting from association response

Wang Chen (1):
      netdevice libertas: Fix directly reference of netdev->priv

Winkler, Tomas (3):
      iwlwifi: reorganize flow handler bitology
      iwlwifi: trivial removal of some 4965 remaining from iwl-agn-rs.h
      iwlwifi: iwl-agn-rs: initialize rs with valid antenna

Zhu Yi (1):
      mac80211: print reason code for deauth/dissoc frames

Zhu, Yi (1):
      iwlwifi: fix priv->iw_mode setting when multiple vif are configur=
ed

 drivers/net/ps3_gelic_wireless.c                   |   17 +-
 drivers/net/ps3_gelic_wireless.h                   |    4 +-
 drivers/net/wireless/Makefile                      |    9 +-
 drivers/net/wireless/adm8211.c                     |   23 -
 drivers/net/wireless/adm8211.h                     |    2 -
 drivers/net/wireless/airo.c                        |   50 +-
 drivers/net/wireless/ath5k/ath5k.h                 |    3 +-
 drivers/net/wireless/ath5k/base.c                  |   12 +-
 drivers/net/wireless/ath5k/pcu.c                   |  184 +-
 drivers/net/wireless/ath5k/reg.h                   |   12 +-
 drivers/net/wireless/ath9k/Makefile                |    4 +
 drivers/net/wireless/ath9k/ani.c                   |  854 ++
 drivers/net/wireless/ath9k/ath9k.h                 |  376 +-
 drivers/net/wireless/ath9k/beacon.c                |   42 +-
 drivers/net/wireless/ath9k/calib.c                 |  930 +++
 drivers/net/wireless/ath9k/core.c                  |  483 +-
 drivers/net/wireless/ath9k/core.h                  |  157 +-
 drivers/net/wireless/ath9k/eeprom.c                | 1605 ++++
 drivers/net/wireless/ath9k/hw.c                    | 8492 +++++-------=
--------
 drivers/net/wireless/ath9k/hw.h                    |    2 +-
 drivers/net/wireless/ath9k/mac.c                   | 1031 +++
 drivers/net/wireless/ath9k/main.c                  |  437 +-
 drivers/net/wireless/ath9k/phy.c                   |   10 +-
 drivers/net/wireless/ath9k/rc.c                    |   90 +-
 drivers/net/wireless/ath9k/recv.c                  |  536 --
 drivers/net/wireless/ath9k/xmit.c                  | 1002 +--
 drivers/net/wireless/atmel.c                       |   70 +-
 drivers/net/wireless/b43/b43.h                     |    1 -
 drivers/net/wireless/b43/main.c                    |  132 +-
 drivers/net/wireless/b43legacy/dma.c               |    2 +-
 drivers/net/wireless/b43legacy/main.c              |   24 -
 drivers/net/wireless/iwlwifi/iwl-3945.h            |    2 -
 drivers/net/wireless/iwlwifi/iwl-4965.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  434 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |   52 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    7 -
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   65 +-
 drivers/net/wireless/libertas/assoc.c              |   18 +-
 drivers/net/wireless/libertas/cmd.c                |    5 +-
 drivers/net/wireless/libertas/dev.h                |    7 +-
 drivers/net/wireless/libertas/main.c               |   39 +-
 drivers/net/wireless/libertas/persistcfg.c         |    2 +-
 drivers/net/wireless/libertas/scan.c               |   77 +-
 drivers/net/wireless/libertas/scan.h               |    4 +
 drivers/net/wireless/libertas/types.h              |    5 +-
 drivers/net/wireless/libertas/wext.c               |    1 -
 drivers/net/wireless/libertas_tf/if_usb.c          |    2 +-
 drivers/net/wireless/mac80211_hwsim.c              |  234 +
 drivers/net/wireless/orinoco/Makefile              |   12 +
 drivers/net/wireless/{ =3D> orinoco}/airport.c       |    0=20
 drivers/net/wireless/{ =3D> orinoco}/hermes.c        |    0=20
 drivers/net/wireless/{ =3D> orinoco}/hermes.h        |    0=20
 drivers/net/wireless/{ =3D> orinoco}/hermes_dld.c    |    0=20
 drivers/net/wireless/{ =3D> orinoco}/hermes_dld.h    |    0=20
 drivers/net/wireless/{ =3D> orinoco}/hermes_rid.h    |    0=20
 drivers/net/wireless/{ =3D> orinoco}/orinoco.c       |   30 +-
 drivers/net/wireless/{ =3D> orinoco}/orinoco.h       |    0=20
 drivers/net/wireless/{ =3D> orinoco}/orinoco_cs.c    |    0=20
 .../net/wireless/{ =3D> orinoco}/orinoco_nortel.c    |    0=20
 drivers/net/wireless/{ =3D> orinoco}/orinoco_pci.c   |    0=20
 drivers/net/wireless/{ =3D> orinoco}/orinoco_pci.h   |    0=20
 drivers/net/wireless/{ =3D> orinoco}/orinoco_plx.c   |    0=20
 drivers/net/wireless/{ =3D> orinoco}/orinoco_tmd.c   |    0=20
 drivers/net/wireless/{ =3D> orinoco}/spectrum_cs.c   |    0=20
 drivers/net/wireless/p54/p54.h                     |    1 +
 drivers/net/wireless/p54/p54common.c               |  452 +-
 drivers/net/wireless/p54/p54common.h               |   31 +-
 drivers/net/wireless/p54/p54pci.c                  |    9 +-
 drivers/net/wireless/p54/p54usb.c                  |   23 +-
 drivers/net/wireless/rndis_wlan.c                  |   24 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |  190 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    2 +
 drivers/net/wireless/rt2x00/rt2500pci.c            |  229 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    2 +
 drivers/net/wireless/rt2x00/rt2500usb.c            |  135 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |    2 +
 drivers/net/wireless/rt2x00/rt2x00.h               |   44 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |  164 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   22 +-
 drivers/net/wireless/rt2x00/rt2x00debug.h          |   13 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   16 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    8 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  254 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    2 +
 drivers/net/wireless/rt2x00/rt73usb.c              |  239 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    2 +
 drivers/net/wireless/rtl8187_dev.c                 |    5 +-
 drivers/net/wireless/rtl8187_rtl8225.c             |  383 +-
 drivers/net/wireless/wl3501.h                      |    4 +-
 drivers/net/wireless/zd1201.c                      |    4 +-
 include/linux/ieee80211.h                          |   10 +
 include/linux/nl80211.h                            |   49 +-
 include/net/cfg80211.h                             |   50 +-
 include/net/mac80211.h                             |   13 +-
 include/net/wireless.h                             |   16 +
 net/ieee80211/ieee80211_wx.c                       |    4 +
 net/mac80211/cfg.c                                 |   45 +
 net/mac80211/ht.c                                  |   10 +-
 net/mac80211/ieee80211_i.h                         |    3 -
 net/mac80211/main.c                                |   15 +-
 net/mac80211/mesh.c                                |    2 +-
 net/mac80211/mesh.h                                |    5 +-
 net/mac80211/mlme.c                                |   38 +-
 net/mac80211/rc80211_minstrel.c                    |    2 +-
 net/mac80211/scan.c                                |    2 +-
 net/mac80211/tx.c                                  |    1 -
 net/mac80211/wext.c                                |   16 -
 net/wireless/nl80211.c                             |   75 +-
 net/wireless/reg.c                                 |  192 +-
 net/wireless/util.c                                |   19 +
 119 files changed, 10031 insertions(+), 10451 deletions(-)
 create mode 100644 drivers/net/wireless/ath9k/ani.c
 create mode 100644 drivers/net/wireless/ath9k/calib.c
 create mode 100644 drivers/net/wireless/ath9k/eeprom.c
 create mode 100644 drivers/net/wireless/ath9k/mac.c
 create mode 100644 drivers/net/wireless/orinoco/Makefile
 rename drivers/net/wireless/{ =3D> orinoco}/airport.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/hermes.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/hermes.h (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/hermes_dld.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/hermes_dld.h (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/hermes_rid.h (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco.c (99%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco.h (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco_cs.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco_nortel.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco_pci.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco_pci.h (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco_plx.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/orinoco_tmd.c (100%)
 rename drivers/net/wireless/{ =3D> orinoco}/spectrum_cs.c (100%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2008-11-10.patch.bz2

--=20
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
