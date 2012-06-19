From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-06-19
Date: Tue, 19 Jun 2012 15:57:57 -0400
Message-ID: <20120619195757.GA7466@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit b3c911eeb47d08aada986f769b6a060794dfe9d0

Dave,

This is a sizeable batch of updates intended for 3.6...

The bulk of the changes here are Bluetooth.  Gustavo says:

	Here goes the first Bluetooth pull request for 3.6, we have
	queued quite a lot of work. Andrei Emeltchenko added the AMP
	Manager code, a lot of work is needed, but the first bit are
	already there. This code is disabled by default.  Mat Martineau
	changed the whole L2CAP ERTM state machine code, replacing
	the old one with a new implementation. Besides that we had
	lot of coding style fixes (to follow net rules), more l2cap
	core separation from socket and many clean ups and fixed all
	over the tree.

Along with the above, there is a healthy dose of ath9k, iwlwifi,
and other driver updates.  There is also another pull from the
wireless tree to resolve some merge issues.  I also fixed-up some
merge discrepencies between net-next and wireless-next.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 43b03f1f6d6832d744918947d185a7aee89d1e0f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-06-12=
 21:59:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Andre Guedes (4):
      Bluetooth: Change default MTU for L2CAP ATT channel
      Bluetooth: Check MTU value in l2cap_sock_setsockopt_old
      Bluetooth: Rename L2CAP_LE_DEFAULT_MTU
      Bluetooth: Filter duplicated reports in LE scan

Andrei Emeltchenko (35):
      Bluetooth: Silent sparse warnings
      Bluetooth: Use defined link key size
      Bluetooth: Preserve L2CAP flags values
      Bluetooth: trivial: Remove empty line
      Bluetooth: Define L2CAP conf continuation flag
      Bluetooth: Define and use PSM identifiers
      Bluetooth: Use __constant when dealing with constants
      Bluetooth: Use __constant modifier in HCI code
      Bluetooth: Define HCI AMP cmd struct
      Bluetooth: Move clean up code and set of SOCK_ZAPPED to l2cap_sock.c
      Bluetooth: Add l2cap_chan->ops->ready()
      Bluetooth: trivial: Use defined PSMLEN instead of magic
      Bluetooth: A2MP: Create A2MP channel
      Bluetooth: A2MP: AMP Manager basic functions
      Bluetooth: A2MP: Build and Send msg helpers
      Bluetooth: A2MP: Add chan callbacks
      Bluetooth: A2MP: Definitions for A2MP commands
      Bluetooth: A2MP: Define A2MP status codes
      Bluetooth: A2MP: Process A2MP messages
      Bluetooth: A2MP: Process A2MP Command Reject
      Bluetooth: A2MP: Process A2MP Discover Request
      Bluetooth: A2MP: Process A2MP Change Notify
      Bluetooth: A2MP: Process A2MP Get Info Request
      Bluetooth: A2MP: Process A2MP Get AMP Assoc Request
      Bluetooth: A2MP: Process A2MP Create Physlink Request
      Bluetooth: A2MP: Process A2MP Disc Physlink Request
      Bluetooth: A2MP: Process A2MP Command Responses
      Bluetooth: A2MP: Handling fixed channels
      Bluetooth: A2MP: Manage incoming connections
      Bluetooth: Do not check func ready existence
      Bluetooth: A2MP: Do not reference hci_conn
      Bluetooth: Make l2cap_data_channel return void
      Bluetooth: Make l2cap_conless_channel return void
      Bluetooth: Make l2cap_att_channel return void
      Bluetooth: Remove magic disconnect reason

Andrzej Kaczmarek (3):
      Bluetooth: Allow only one LE connection attempt
      Bluetooth: Return proper mgmt state when LE pairing connection failed
      Bluetooth: Fix not removing hci_conn for failed LE connection

Arend van Spriel (4):
      brcmsmac: remove brcms_set_hint() function
      brcmsmac: fix smatch warning found in ampdu.c
      brcmfmac: add debugfs helper functions
      brcmfmac: expose sdio internal counters in debugfs

Ashok Nagarajan (1):
      mac80211: add missing kernel-doc

Avinash Patil (1):
      mwifiex: fix incorrect privacy setting in beacon and probe response

Bing Zhao (1):
      Bluetooth: btmrvl: add SD8787 Bluetooth AMP device ID

Brandon Misemer (1):
      iwlwifi: Fix Makefile build order for built-in driver

Dan Carpenter (2):
      iwlwifi: turn on a lockdep assertion
      iwlwifi: unlock on error path

David Spinadel (1):
      mac80211: stop polling in disassociation

Eliad Peller (2):
      cfg80211: fix potential deadlock in regulatory
      mac80211: check sdata_running on ieee80211_set_bitrate_mask

Emmanuel Grumbach (10):
      iwlwifi: s/iwl_read_targ_mem_words/iwl_read_targ_mem_bytes
      iwlwifi: iwl_{read,write}_targ_mem_words takes dwords
      iwlwifi: print more info when a queue is stuck
      iwlwifi: don't configure a txq that is being disabled
      iwlwifi: remove lock around txq_enable
      iwlwifi: comment that setting driver_data overrides info->control
      iwlwifi: print even more info when a queue is stuck
      iwlwifi: don't modify the timer if we don't Tx
      iwlwifi: warn if TFD index and WiFi Seq don't match
      iwlwifi: WARN only once when we have trouble in reclaim

Gustavo Padovan (29):
      Bluetooth: Fix coding style in mgmt.c
      Bluetooth: Fix coding style in sco.c
      Bluetooth: Fix coding style in hci_sock.c
      Bluetooth: Fix coding style in hci_sysfs.c
      Bluetooth: Fix coding style in hci_event.c
      Bluetooth: Fix coding style in hci_conn.c
      Bluetooth: Fix coding style in hci_core.c
      Bluetooth: Do not purge queue in Basic Mode
      Bluetooth: Remove double check for BT_CONNECTED
      Bluetooth: Remove dead int returns
      Bluetooth: Fix trailing whitespaces in license text
      Bluetooth: Remove most of the inline usage
      Bluetooth: Remove 'register' usage from the subsystem
      Bluetooth: Fix coding style in include/net/bluetooth
      Bluetooth: Fix coding style in the subsystem
      Bluetooth: Remove unnecessary headers include
      Bluetooth: Remove unneeded EXPORT_SYMBOL
      Bluetooth: Use lmp_ssp_capable() macro
      Bluetooth: Get a more accurate L2CAP PDU len
      Bluetooth: Remove extra l2cap_state_change(BT_CONNECTED)
      Bluetooth: Use l2cap_chan_ready() in LE path
      Bluetooth: Use chan as parameters for l2cap chan ops
      Bluetooth: Use chan->state instead of sk->sk_state
      Bluetooth: Move check for backlog size to l2cap_sock.c
      Bluetooth: check for already existent channel before create new one
      Bluetooth: Create function to return the ERTM header size
      Bluetooth: Remove unused err var from l2cap_segment_sdu()
      Bluetooth: Create empty l2cap ops function
      Bluetooth: Fix style in hidp code

Ilan Peer (2):
      iwlwifi: refactor testmode
      iwlwifi: decouple testmode and iwl-test

Johan Hedberg (4):
      Bluetooth: Fix SMP pairing method selection
      Bluetooth: Fix deadlock and crash when SMP pairing times out
      Bluetooth: Fix SMP security elevation from medium to high
      Bluetooth: Add support for encryption key refresh

Johannes Berg (5):
      mac80211: add some missing kernel-doc
      iwlwifi: fix dynamic loading
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: fix 6035 device parameters
      iwlwifi: use request_module instead of _nowait

John W. Linville (6):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jussi Kivilinna (1):
      rndis_wlan: fix matching bssid check in rndis_check_bssid_list()

Mat Martineau (28):
      Bluetooth: Free allocated ERTM SREJ list if init fails
      Bluetooth: Fix early return from l2cap_chan_del
      Bluetooth: Change default state of ERTM disable flag
      Bluetooth: Add a new L2CAP ERTM transmit state machine.
      Bluetooth: Refactor l2cap_streaming_send
      Bluetooth: Refactor l2cap_ertm_send
      Bluetooth: Refactor l2cap_send_sframe
      Bluetooth: Consolidate common receive code for ERTM and streaming mode
      Bluetooth: Add streaming mode receive and incoming packet classifier
      Bluetooth: Remove receive code that has been superceded
      Bluetooth: Refactor l2cap_send_ack
      Bluetooth: Use the transmit state machine for busy state changes
      Bluetooth: Update l2cap_send_i_or_rr_or_rnr to fit the spec better
      Bluetooth: Add the ERTM receive state machine
      Bluetooth: Add implementation for retransmitting all unacked frames
      Bluetooth: Send SREJ frames when packets go missing
      Bluetooth: Reassemble all available data when retransmissions succeed.
      Bluetooth: Handle SREJ requests to resend unacked frames
      Bluetooth: Handle incoming REJ frames
      Bluetooth: Use new header structures in l2cap_send_rr_or_rnr
      Bluetooth: Check rules when setting retransmit or monitor timers
      Bluetooth: Use the ERTM transmit state machine from timeout handlers
      Bluetooth: Simplify the ERTM ack timeout
      Bluetooth: Remove unneccesary inline
      Bluetooth: Set txwin values for streaming mode
      Bluetooth: Remove unused ERTM control field macros
      Bluetooth: Enable ERTM by default
      Bluetooth: Send a configuration request after security confirmation

Michal Kazior (1):
      cfg80211: check iface combinations only when iface is running

Mohammed Shafi Shajakhan (4):
      ath9k: Fix a WARNING on suspend/resume with IBSS
      ath9k: remove incompatible IBSS interface check in change_iface
      ath9k: Fix softlockup in AR9485
      ath9k: Fix softlockup in AR9485

Rajkumar Manoharan (19):
      ath9k: choose legacy rate as last rate of MRR series
      ath9k: restore power state on set channel failure
      ath9k_hw: Fix AR9462 power consumption on idle associated
      ath9k_hw: check GPM HW write pointer before chip reset
      ath9k_hw: fix incorrect LNA register settings
      ath9k_hw: program OBS register only when MCI is disabled
      ath9k_hw: process MCI interrupts only when btcoex is enabled
      ath9k: simplify btcoex profile management
      ath9k: keep btcoex period in milliseconds
      ath9k: defer btcoex scheme update
      ath9k: fix btcoex duty cycle
      ath9k_hw: cleanup MCI gpm offset state
      ath9k_hw: add utility function to set BT version
      ath9k_hw: remove MCI_STATE_SEND_WLAN_CHANNELS
      ath9k_hw: remove MCI_STATE_NEED_FLUSH_BT_INFO
      ath9k_hw: remove p_data argument from ar9003_mci_state
      ath9k_hw: remove MCI_STATE_BT
      ath9k_hw: remove MCI_STATE_CONT_* state
      ath9k_hw: remove MCI_STATE_SET_BT_SLEEP

Sasha Levin (1):
      Bluetooth: Really fix registering hci with duplicate name

Sujith Manoharan (1):
      ath9k_hw: Update initvals for AR9462

Szymon Janc (2):
      Bluetooth: Rename HCI_QUIRK_NO_RESET to HCI_QUIRK_RESET_ON_CLOSE
      Bluetooth: Remove unused HCI timeouts definitions

Vinicius Costa Gomes (1):
      Bluetooth: Fix checking the wrong flag when accepting a socket

Vishal Agarwal (1):
      Bluetooth: Fix LE pairing completion on connection failure

 drivers/bluetooth/bluecard_cs.c                    |   10 +-
 drivers/bluetooth/bpa10x.c                         |    2 +-
 drivers/bluetooth/bt3c_cs.c                        |    4 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    3 +
 drivers/bluetooth/btuart_cs.c                      |    4 +-
 drivers/bluetooth/btusb.c                          |   14 +-
 drivers/bluetooth/dtl1_cs.c                        |    4 +-
 drivers/bluetooth/hci_bcsp.c                       |    2 +-
 drivers/bluetooth/hci_h4.c                         |    2 +-
 drivers/bluetooth/hci_ldisc.c                      |    2 +-
 drivers/bluetooth/hci_ll.c                         |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    7 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |  330 ++--
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |   32 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/gpio.c              |   10 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   11 +-
 drivers/net/wireless/ath/ath9k/link.c              |    8 +
 drivers/net/wireless/ath/ath9k/main.c              |   22 +-
 drivers/net/wireless/ath/ath9k/mci.c               |  162 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   17 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |  126 ++
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   59 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    7 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  169 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    5 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   14 +-
 drivers/net/wireless/iwlwifi/Makefile              |   10 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   17 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   26 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |    6 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |   24 +-
 drivers/net/wireless/iwlwifi/dvm/testmode.c        |  778 +-------
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   38 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    2 +
 drivers/net/wireless/iwlwifi/iwl-io.c              |   20 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   14 +-
 drivers/net/wireless/iwlwifi/iwl-test.c            |  856 ++++++++
 drivers/net/wireless/iwlwifi/iwl-test.h            |  161 ++
 .../iwlwifi/{dvm/testmode.h =3D> iwl-testmode.h}     |    0
 drivers/net/wireless/iwlwifi/pcie/6000.c           |    1 +
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    9 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   71 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   95 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   11 +
 drivers/net/wireless/rndis_wlan.c                  |    2 +-
 include/net/bluetooth/a2mp.h                       |  126 ++
 include/net/bluetooth/bluetooth.h                  |   39 +-
 include/net/bluetooth/hci.h                        |  105 +-
 include/net/bluetooth/hci_core.h                   |   29 +-
 include/net/bluetooth/l2cap.h                      |  205 +--
 include/net/mac80211.h                             |    6 +
 net/bluetooth/Makefile                             |    3 +-
 net/bluetooth/a2mp.c                               |  568 ++++++
 net/bluetooth/af_bluetooth.c                       |   14 +-
 net/bluetooth/bnep/core.c                          |   21 +-
 net/bluetooth/bnep/netdev.c                        |   16 +-
 net/bluetooth/bnep/sock.c                          |   18 +-
 net/bluetooth/hci_conn.c                           |   98 +-
 net/bluetooth/hci_core.c                           |  214 +-
 net/bluetooth/hci_event.c                          |  357 ++--
 net/bluetooth/hci_sock.c                           |   59 +-
 net/bluetooth/hci_sysfs.c                          |   99 +-
 net/bluetooth/hidp/core.c                          |   26 +-
 net/bluetooth/hidp/sock.c                          |   16 +-
 net/bluetooth/l2cap_core.c                         | 2132 ++++++++++++----=
----
 net/bluetooth/l2cap_sock.c                         |  130 ++-
 net/bluetooth/lib.c                                |    7 +-
 net/bluetooth/mgmt.c                               |   89 +-
 net/bluetooth/rfcomm/core.c                        |   32 +-
 net/bluetooth/rfcomm/sock.c                        |   21 +-
 net/bluetooth/rfcomm/tty.c                         |    9 +-
 net/bluetooth/sco.c                                |   43 +-
 net/bluetooth/smp.c                                |   18 +-
 net/mac80211/cfg.c                                 |    3 +
 net/mac80211/mlme.c                                |    4 +-
 net/mac80211/sta_info.h                            |    5 +
 net/wireless/reg.c                                 |    2 +-
 net/wireless/util.c                                |    2 +-
 86 files changed, 4743 insertions(+), 2966 deletions(-)
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-test.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-test.h
 rename drivers/net/wireless/iwlwifi/{dvm/testmode.h =3D> iwl-testmode.h} (=
100%)
 create mode 100644 include/net/bluetooth/a2mp.h
 create mode 100644 net/bluetooth/a2mp.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP4NnEAAoJEJctW/TcYTgGn/EP/iHdQjF7Vf2MwD37RqPzU+4T
MxkLrFFbjQwcSHSDrrJBGuHd3mogPvxM2/nSRG9iXyS+t6kJ8+1SDZwekiT9AMXM
6wzS+wftE7pfX3BL4KEJttjCaleifcd1SRD4lb95Bs4qA4xtpSKK/XIg4T5yQF3y
7Xg/IG4n2hM/3UVLD7g2SdxF7OOl58QHOR+Fopn8H9uRHnH8+pf2nScPBVjudyp3
T/qlpKpKn+c4bNSIJz1O8159UA7sF04n1pfQKpB+VnYipkeWBgYKAWuWJabJf28x
rAwINP3IMlzO3VwLUrUpHLFDy/BJ4C7BlROoEMJ4e68FmEPEBpgDIcLy9LFH/wwM
lkvGAXpvzQIxodzZghMTPOnCVlVLAFZ2kaTy0T0d02/p9fdjn9EGX3VT3+ZRqtap
RysQw6o0frcnQeEHiJI1TW9i85THjUwbICCOrAEiH485/TLCcAwDEBeHvromtezd
fz+vcMvTsuCQj8zzVPw4AXsKacbDwfYcYCSNcyg1Cq4qdHKPAH2YtUHPj5lRWrEX
U/Ng6syU7OhwPCHLtSVXroIgNPqN+kRABYNVfJkYKeDyMMh0QCQbfTJbmmUyWTSq
4W1mLfBZ8mdJtVFQ01lmPY7/ROHAm5MrrIcfUg77c6oB82nowZ9qr+rbDUgC9jKB
E3/DA9mhOXS9OV2ZZdjw
=AoKg
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
