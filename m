From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-08-01
Date: Fri, 1 Aug 2014 12:57:38 -0400
Message-ID: <20140801165738.GA26953@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this last(?) batch of wireless change intended for the
3.17 stream...

For the NFC bits, Samuel says:

"This is a rather quiet one, we have:

- A new driver from ST Microelectronics for their NCI ST21NFCB,
  including device tree  support.

- p2p support for the ST21NFCA driver

- A few fixes an enhancements for the NFC digital laye"

For the Atheros bits, Kalle says:

"Michal and Janusz did some important RX aggregation fixes, basically we
were missing RX reordering altogether. The 10.1 firmware doesn't support
Ad-Hoc mode and Michal fixed ath10k so that it doesn't advertise Ad-Hoc
support with that firmware. Also he implemented a workaround for a KVM
issue."

For the Bluetooth bits, Gustavo and Johan say:

"To quote Gustavo from his previous request:

'Some last minute fixes for -next. We have a fix for a use after free in
RFCOMM, another fix to an issue with ADV_DIRECT_IND and one for ADV_IND with
auto-connection handling.  Last, we added support for reading the codec and
MWS setting for controllers that support these features.'

Additionally there are fixes to LE scanning, an update to conform to the 4.1
core specification as well as fixes for tracking the page scan state. All
of these fixes are important for 3.17."

And,

"We've got:

- 6lowpan fixes/cleanups
- A couple crash fixes, one for the Marvell HCI driver and another in LE SM=
P.
- Fix for an incorrect connected state check
- Fix for the bondable requirement during pairing (an issue which had
  crept in because of using "pairable" when in fact the actual meaning
  was "bondable" (these have different meanings in Bluetooth)"

Along with those are some late-breaking hardware support patches in
brcmfmac and b43 as well as a stray ath9k patch.

Please let me know if there are problems!

Thanks,

John

P.S.  It looks like there are a number of minor merge conflicts
resulting from Marcel's 6lowpan style cleanups.  I don't think you
will have any issues resolving them, but if you do then let me know
how I can help!

---

The following changes since commit 9a244409d0b0cf3b1e46f1dc331f2c718597fae0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless (2014-07-25 10:22:36 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-07-31

for you to fetch changes up to dc6be9f54a4ecb0a09765d1f515ed947d86b7528:

  bcma: use NS prefix for names of Northstar specific cores (2014-07-31 13:=
45:32 -0400)

----------------------------------------------------------------
Alexander Aring (8):
      MAINTAINERS: add 6lowpan header file
      6lowpan: iphc: rename hc06_ptr pointer to hc_ptr
      6lowpan: iphc: use sizeof in udp uncompression
      6lowpan: iphc: cleanup use of lowpan_fetch_skb
      6lowpan: iphc: cleanup use of lowpan_push_hc_data
      6lowpan: iphc: use ipv6 api to check address scope
      6lowpan: iphc: remove check on null
      6lowpan: remove unused LOWPAN_FRAG_SIZE define

Anatol Pomozov (1):
      Bluetooth: Fix crash in the Marvell driver initialization codepath

Arend van Spriel (1):
      dt: bindings: add bindings for Broadcom bcm43xx sdio devices

Bing Zhao (1):
      MAINTAINERS: update for mwifiex driver maintainers

Chen-Yu Tsai (1):
      brcmfmac: add device tree support for SDIO devices

Christophe Ricard (10):
      NFC: st21nfcb: Add driver for STMicroelectronics ST21NFCB NFC chip
      NFC: dts: st21nfcb_i2c: Add DTS Documentation
      NFC: nci: Add T1T support notification
      NFC: st21nfcb: few code clean up
      NFC: st21nfca: Free buffer in case no data are retrieved.
      NFC: st21nfca: Improved start of frame detection
      NFC: st21nfca: Improve read length sequence for P2P mode.
      NFC: hci: Add stop_poll HCI operand.
      NFC: st21nfca: Implement stop_poll HCI hook
      NFC: st21nfca: Adding P2P support to st21nfca in Initiator & Target m=
ode

Daniel Kim (1):
      brcmfmac: Do not use strcpy and strcat

Georg Lukas (2):
      Bluetooth: Provide defaults for LE advertising interval
      Bluetooth: Expose default LE advertising interval via debugfs

Hans de Goede (2):
      brcmfmac: Fix some wrong register defines
      brcmfmac: Fix OOB interrupt not working for BCM43362

Hante Meuleman (7):
      brcmfmac: Export brcmf_netif_rx for new protocol msgbuf.
      brcmfmac: Add protocol addressing mode and peer deletion API.
      brcmfmac: Adding msgbuf protocol.
      brcmfmac: Adding PCIe bus layer support.
      brcmfmac: Update pcie reset device routine.
      brcmfmac: Fix msgbuf flow control.
      brcmfmac: Add TDLS support to msgbuf.

Janusz Dziedzic (1):
      ath10k: handle attention flags correctly when using A-MSDU

Johan Hedberg (7):
      Bluetooth: Fix clearing HCI_PSCAN flag
      Bluetooth: Fix incorrectly disabling page scan when toggling connecta=
ble
      Bluetooth: Fix SMP context tracking leading to a kernel crash
      Bluetooth: Fix check for connected state when pairing
      Bluetooth: Rename HCI_PAIRABLE to HCI_BONDABLE
      Bluetooth: Rename pairable mgmt setting to bondable
      Bluetooth: Always use non-bonding requirement when not bondable

John W. Linville (3):
      Merge tag 'nfc-next-3.17-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge tag 'for-linville-20140725' of git://github.com/kvalo/ath
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next

Julia Lawall (1):
      iwlegacy: use correct structure type name in sizeof

Kalle Valo (1):
      Merge remote-tracking branch 'wireless-next/master' into ath-next

Marcel Holtmann (13):
      Bluetooth: Read list of local codecs supported by the controller
      Bluetooth: Get MWS transport configuration of the controller
      Bluetooth: Ignore ADV_DIRECT_IND attempts from unknown devices
      Bluetooth: Fix issue with ADV_IND reports and auto-connection handling
      Bluetooth: Add support for using controller white list filtering
      Bluetooth: Fix white list handling with resolvable private addresses
      Bluetooth: Set Simultaneous LE and BR/EDR controller option to zero
      6lowpan: iphc: Fix block comments to match networking style
      6lowpan: iphc: Fix issues with alignment matching open parenthesis
      6lowpan: iphc: Fix missing blank line after variable declarations
      6lowpan: iphc: Fix missing braces for if statement
      6lowpan: iphc: Fix parenthesis alignments which off-by-one
      Bluetooth: Fix sparse warning from HID new leds handling

Mark A. Greer (5):
      NFC: digital: Check for NFC-DEP before checking for Type 4 tag
      NFC: digital: Clear poll_tech_count before activating target
      NFC: digital: Add digital framing calls when in target mode
      NFC: digital: Remove extra blank line
      NFC: digital: Add 'tg_listen_md' and 'tg_get_rf_tech' driver hooks

Michal Kazior (7):
      ath10k: workaround boot issues with KVM/PCI-passthrough
      ath10k: prevent some tx flushing failures
      ath10k: simplify tx helpers
      ath10k: workaround qos nullfunc bug
      ath10k: prevent endless pci rx loop
      ath10k: fix Rx aggregation reordering
      ath10k: don't advertise IBSS iftype for 10.x

Rafa=C5=82 Mi=C5=82ecki (5):
      b43: add support for BCM43131 chipset with N-PHY rev 17
      bcma: add support for BCM43131 that was found in Tenda W311E
      b43: update PHY descriptions in Kconfig
      b43: N-PHY: fix "Data bus error" while working in 5 GHz
      bcma: use NS prefix for names of Northstar specific cores

Rajkumar Manoharan (1):
      ath9k: Initialize channel context ops on ahb probe

Varka Bhadram (2):
      6lowpan: remove unused macros
      6lowpan: remove unused function

Vignesh Raman (1):
      Bluetooth: Avoid use of session socket after the session gets freed

 .../devicetree/bindings/net/nfc/st21nfcb.txt       |   33 +
 .../bindings/net/wireless/brcm,bcm43xx-fmac.txt    |   41 +
 MAINTAINERS                                        |    4 +-
 drivers/bcma/driver_chipcommon_pmu.c               |    1 +
 drivers/bcma/host_pci.c                            |    1 +
 drivers/bcma/scan.c                                |   22 +-
 drivers/bcma/sprom.c                               |    1 +
 drivers/bluetooth/btmrvl_main.c                    |    5 +
 drivers/net/wireless/ath/ath10k/htc.c              |   20 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  122 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    6 +
 drivers/net/wireless/ath/ath10k/mac.c              |   96 +-
 drivers/net/wireless/ath/ath10k/mac.h              |    4 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   17 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    3 +-
 drivers/net/wireless/ath/ath10k/txrx.h             |    1 +
 drivers/net/wireless/ath/ath10k/wmi.c              |    2 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |    1 +
 drivers/net/wireless/b43/Kconfig                   |   22 +-
 drivers/net/wireless/b43/main.c                    |    3 +-
 drivers/net/wireless/b43/phy_n.c                   |    6 +-
 drivers/net/wireless/brcm80211/Kconfig             |   10 +
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    7 +
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |   20 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   20 +
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |    8 +
 .../net/wireless/brcm80211/brcmfmac/commonring.c   |  273 +++
 .../net/wireless/brcm80211/brcmfmac/commonring.h   |   69 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    7 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   33 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   36 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    9 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   25 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |  501 ++++++
 drivers/net/wireless/brcm80211/brcmfmac/flowring.h |   84 +
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |    5 +
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   | 1397 +++++++++++++++
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h   |   40 +
 drivers/net/wireless/brcm80211/brcmfmac/of.c       |   56 +
 drivers/net/wireless/brcm80211/brcmfmac/of.h       |   22 +
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     | 1846 ++++++++++++++++=
++++
 drivers/net/wireless/brcm80211/brcmfmac/pcie.h     |   29 +
 drivers/net/wireless/brcm80211/brcmfmac/proto.c    |   29 +-
 drivers/net/wireless/brcm80211/brcmfmac/proto.h    |   31 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   12 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   57 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   11 +
 drivers/net/wireless/iwlegacy/common.c             |    3 +-
 drivers/nfc/Kconfig                                |    2 +-
 drivers/nfc/Makefile                               |    3 +-
 drivers/nfc/st21nfca/Makefile                      |    2 +-
 drivers/nfc/st21nfca/i2c.c                         |    9 +-
 drivers/nfc/st21nfca/st21nfca.c                    |  272 ++-
 drivers/nfc/st21nfca/st21nfca.h                    |   26 +-
 drivers/nfc/st21nfca/st21nfca_dep.c                |  661 +++++++
 drivers/nfc/st21nfca/st21nfca_dep.h                |   43 +
 drivers/nfc/st21nfcb/Kconfig                       |   22 +
 drivers/nfc/st21nfcb/Makefile                      |    8 +
 drivers/nfc/st21nfcb/i2c.c                         |  462 +++++
 drivers/nfc/st21nfcb/ndlc.c                        |  298 ++++
 drivers/nfc/st21nfcb/ndlc.h                        |   55 +
 drivers/nfc/st21nfcb/st21nfcb.c                    |  129 ++
 drivers/nfc/st21nfcb/st21nfcb.h                    |   38 +
 include/linux/bcma/bcma.h                          |   23 +-
 include/linux/platform_data/st21nfcb.h             |   32 +
 include/net/6lowpan.h                              |   50 -
 include/net/bluetooth/hci.h                        |    6 +-
 include/net/bluetooth/hci_core.h                   |    3 +
 include/net/bluetooth/mgmt.h                       |    4 +-
 include/net/nfc/digital.h                          |   13 +
 include/net/nfc/hci.h                              |    1 +
 net/6lowpan/iphc.c                                 |  295 ++--
 net/bluetooth/hci_core.c                           |  185 +-
 net/bluetooth/hci_event.c                          |   50 +-
 net/bluetooth/hidp/core.c                          |    2 +-
 net/bluetooth/mgmt.c                               |   57 +-
 net/bluetooth/rfcomm/core.c                        |    7 +-
 net/bluetooth/smp.c                                |   33 +-
 net/nfc/digital.h                                  |    3 +
 net/nfc/digital_core.c                             |   27 +-
 net/nfc/digital_dep.c                              |   11 +-
 net/nfc/digital_technology.c                       |   96 +-
 net/nfc/hci/core.c                                 |    7 +-
 net/nfc/nci/ntf.c                                  |    4 +-
 85 files changed, 7579 insertions(+), 417 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/st21nfcb.txt
 create mode 100644 Documentation/devicetree/bindings/net/wireless/brcm,bcm=
43xx-fmac.txt
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/commonring.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/commonring.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/flowring.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/flowring.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/of.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/of.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/pcie.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/pcie.h
 create mode 100644 drivers/nfc/st21nfca/st21nfca_dep.c
 create mode 100644 drivers/nfc/st21nfca/st21nfca_dep.h
 create mode 100644 drivers/nfc/st21nfcb/Kconfig
 create mode 100644 drivers/nfc/st21nfcb/Makefile
 create mode 100644 drivers/nfc/st21nfcb/i2c.c
 create mode 100644 drivers/nfc/st21nfcb/ndlc.c
 create mode 100644 drivers/nfc/st21nfcb/ndlc.h
 create mode 100644 drivers/nfc/st21nfcb/st21nfcb.c
 create mode 100644 drivers/nfc/st21nfcb/st21nfcb.h
 create mode 100644 include/linux/platform_data/st21nfcb.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJT28cCAAoJEJctW/TcYTgGD/4P/0HMUDJwNxkJmUB+R/UdrTzD
veEi0acHh3KDDjpO0M9GxFvXkynHZmrNeJ3pcrehw8nqSThzFs7oBspgctpP6Yf3
CvhuoQ486iHH4ZgDK81sIQE7xaS2gTvozUPN1e2aIMQBq60QAKsufwo3utDAcWaO
7mb1fbcMqhvMprrghyzPr+mh/bcwc6R8VG2SdNsa0Fdx4Lnhn6seMkffFixZw+6g
oW8SLyHyx/53QA3LizCnQo3Vcnq075d5+frmhd9U22is04HEza4eBrFWhaNWV+03
Yf4UKS7cJxrBJvsi+fNV51ZoViC6TGjzRC1TpcgnaUqY7hkgslXTTB61/KMJsJb8
dgE8b8rQmZeRxEHjnLLBL0hJ27iV48Rv/ojSt8KxpfqascsrdNnKpHNfstHrlZXq
qBeI02Emi49aHJjE+BOxPsJjIhc8Z+cAzQ+zvMQ2dYMNP1Q65lz8K81TAq9PVPM9
c6V8h37Ua/n2L6hP01ew4qys0wqcjY6Y3Di8JIGg4UfK+sCvTR/rAC1U4uYu92zX
kascyOzta7veUDbRk6/1/fgtzPO9kCnw6205f3xiRNL869VDHRaYRofy+RSdVe5y
s6WTIWFAf6jAnfF1hfwi2Nf7M6Giu99DVd5OCcmQ984BuNzJQ2FS4TQ/LtwUrPQj
TvTAflkIQ2zBlQ5yqz+p
=+3hC
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
