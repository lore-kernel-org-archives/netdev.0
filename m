From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next 2014-05-27
Date: Tue, 27 May 2014 14:19:09 -0400
Message-ID: <20140527181909.GE5694@tuxdriver.com>
References: <20140527181200.GD5694@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ftEhullJWpWg/VHq"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140527181200.GD5694@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ftEhullJWpWg/VHq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I bodged Dave's address on the first round -- just making sure he
sees this!

On Tue, May 27, 2014 at 02:12:01PM -0400, John W. Linville wrote:
> Dave,
>=20
> Please pull this batch of updates intended for 3.16...
>=20
> For the mac80211 bits, Johannes says:
>=20
> "Here I just have Heikki's rfkill GPIO cleanups.
>=20
> The ARM/tegra patch is OK with the maintainer (Stephen). Let me know of
> any problems."
>=20
> and;
>=20
> "We have a whole bunch of work on CSA by Andrei, Luca and Michal, but
> unfortunately it doesn't seem quite complete yet so it's still disabled.
> There's some TDLS work from Arik, and the rest is mostly minor fixes and
> cleanups."
>=20
> For the NFC bits, Samuel says:
>=20
> "This is the NFC pull request for 3.16. We have:
>=20
> - STMicroeectronics st21nfca support. The st21nfca is an HCI chipset and
>   thus relies on the HCI stack. This submission provides support for tag
>   redaer/writer mode (including Type 5) and device tree bindings.
>=20
> - PM runtime support and a bunch of bug fixes for TI's trf7970a.
>=20
> - Device tree support for NXP's pn544. Legacy platform data support is
>   obviously kept intact.
>=20
> - NFC Tag type 4B support to the NFC Digital stack.
>=20
> - SOCK_RAW type support to the raw NFC socket, and allow NCI
>   sniffing from that. This can be extended to report HCI frames and also
>   proprietarry ones like e.g. the pn533 ones."
>=20
> For the iwlwifi bits, Emmanuel says:
>=20
> "Eran continues to work on new devices, Eyal is still digging in
> the rate control stuff, and Johannes added new functionality to the
> debug system we have in place now along with a few cleanups he made
> on the way.  That's pretty much it."
>=20
> and;
>=20
> "Avri continues to work on the power code and Eran is improving the
> NVM handling as a preparations for new devices on which he works
> with Liad. Luca cleans up a bit the code while working on CSA. I have
> the regular BT Coex stuff and a small lockdep fix. Johannes has his
> regular amount of clean ups and improvements, the main one is the
> ability to leave 2 chains open to improve diversity and hence the
> throughput in high attenuation scenarios."
>=20
> and;
>=20
> "The regular amount of housekeeping here. I merged iwlwifi-fixes.git to
> be able to add the patch you didn't want in wireless.git at that stage
> of the -rc cycle.  Luca has a few preparations for CSA implementation
> and also what seems to be a bugfix for P2P but hasn't caused issues
> we could notice."
>=20
> For the Atheros bits, Kalle says:
>=20
> "For ath10k Michal did various small fixes on how we handle
> hardware/firmware problems and he also fixed two memory leaks."
>=20
> Also included are a couple of pulls from the wireless tree to
> avoid/resolve merge issues...
>=20
> Please let me know if there are problems!
>=20
> Thanks,
>=20
> John
>=20
> ---
>=20
> The following changes since commit 3bea8eddfebe1c61ea824dd2880d4368791edc=
1f:
>=20
>   Merge branch 'net-sysfs-docs' (2014-05-26 01:02:39 -0400)
>=20
> are available in the git repository at:
>=20
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.gi=
t for-davem
>=20
> for you to fetch changes up to 9db7cb6901740453a442e598563b576987dd471b:
>=20
>   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/=
linville/wireless-next into for-davem (2014-05-27 13:51:31 -0400)
>=20
> ----------------------------------------------------------------
>=20
> Adam Lee (3):
>       rtlwifi: make MSI support a module parameter
>       rtlwifi: rtl8188ee: add msi module parameter
>       rtlwifi: rtl8723be: add msi module parameter
>=20
> Alexey Khoroshilov (1):
>       carl9170: fix leaks at failure path in carl9170_usb_probe()
>=20
> Andrea Merello (4):
>       rtl8187: report mac80211 short preamble RX flag
>       rtl8180: report mac80211 short preamble RX flag
>       rtl8180: make CTS-to-self protection work
>       rtl8187: make CTS-to-self protection work
>=20
> Andrei Otcheretianski (7):
>       iwlwifi:mvm: Add AP/GO channel switch support
>       cfg80211: Add API to update CSA counters in mgmt frames
>       mac80211: Update CSA counters in mgmt frames
>       cfg80211: Support multiple CSA counters
>       mac80211: Support multiple CSA counters
>       mac80211: Provide ieee80211_beacon_get_template API
>       mac80211: Handle the CSA counters correctly
>=20
> Andy Spencer (1):
>       RTL8192CU: Increase max APFM_ONMAC polling count
>=20
> Antonio Quartulli (3):
>       cfg80211: export expected throughput through get_station()
>       mac80211: export the expected throughput
>       cfg80211: implement cfg80211_get_station cfg80211 API
>=20
> Arend van Spriel (8):
>       brcmfmac: enhance nvram processing
>       brcmfmac: remove usage of cfg80211_get_chandef_type()
>       brcm80211: extend channel conversion functions for 80MHz support
>       brcmfmac: provide VHT capability information to user-space
>       brcmfmac: enable 80Mhz in 5G custom regulatory rules
>       brcmfmac: get rid of brcmf_cfg80211_set_channel() function
>       brcmfmac: handle 80MHz chanspecs in construct_reg_info() function
>       brcmfmac: determine chanspec from struct cfg80211_chan_def info
>=20
> Arik Nemtsov (4):
>       mac80211: set an external flag for TDLS stations
>       mac80211: move TDLS code to another file
>       cfg80211: don't set reg timeout for user-handled hint
>       iwlwifi: mvm: remove vif argument from power_update_mac
>=20
> Avinash Patil (10):
>       mwifiex: configure inactivity timeout for TDLS link
>       mwifiex: disable TDLS link upon tear down event
>       mwifiex: add HT operation IE in TDLS setup confirm
>       mwifiex: restore current SDIO write port in failure cases
>       mwifiex: set valid tx_param during mwifiex_send_null_packet
>       mwifiex: avoid TDLS check for packets destined to AP
>       mwifiex: silence TDLS link delete failure for nonexistent link
>       mwifiex: delete TDLS link upon Teardown event
>       mwifiex: set TDLS flags for AMSDU packets
>       mwifiex: update seq number correctly for packets from TDLS peer
>=20
> Avri Altman (4):
>       iwlwifi: mvm: Add power management support for P2P DCM
>       iwlwifi: mvm: Disable uAPSD for a DCM client
>       iwlwifi: mvm: Remove redundant initialization
>       iwlwifi: mvm: don't filter out the first beacon
>=20
> Ben Greear (1):
>       ath9k: Prevent divide-by-zero upon bad beacon_interval.
>=20
> Christophe Ricard (22):
>       NFC: ST21NFCA: Add driver for STMicroelectronics ST21NFCA NFC Chip
>       NFC: hci: Extend command execution delay
>       NFC: hci: Add load_session HCI operand
>       NFC: st21nfca: Implement load_session HCI hook
>       NFC: st21nfca: Fix sparse: cast to restricted __be16
>       NFC: hci: Fix sparse: cast to restricted __be16
>       NFC: st21nfca: Fix warning: array subscript is above array bounds
>       NFC: st21nfca: Remove sporadic wait_tab variable from functions.
>       NFC: st21nfca: Add __packed to struct st21nfca_pipe_info
>       NFC: st21nfca: st21nfca_hci_i2c_probe returns st21nfca_hci_probe re=
sult.
>       NFC: st21nfca: Reworked st21nfca_request_resources
>       NFC: st21nfca: Improve st21nfca initialization by handling reboot p=
roperly
>       NFC: st21nfca: Remove few useless include
>       NFC: st21nfca: Fix incorrect byte stuffing revocation
>       NFC: st21nfca: Fix st21nfca_hci_remove_len_crc tail room handling
>       NFC: st21nfca: Improved i2c Rx data correctness check
>       NFC: st21nfca: Synchronize i2c Tx and Rx path
>       NFC: st21nfca: Free buffer when a bad frame is detected
>       NFC: dts: st21nfca: Add device-tree (Open Firmware) support to st21=
nfca
>       NFC: dts: st21nfca_i2c: Add DTS Documentation
>       NFC: st21nfca: Improve load_session
>       NFC: st21nfca: Add ISO15693 Reader/Writer support
>=20
> Clement Perrochaud (3):
>       NFC: pn544: i2c: Add device-tree (Open Firmware) support to PN544
>       NFC: pn544: i2c: Add DTS Documentation
>       NFC: pn544_i2c: Fix null pointer exception when not using platform =
data
>=20
> Dan Williams (1):
>       libertas: fix return value when processing invalid packet
>=20
> Daniel Kim (3):
>       brcmfmac: Give priority to 5GHz band in selecting target BSS
>       brcmfmac: Report the support of firmware roaming
>       brcmfmac: Fix reconnect failure after beacon timeout
>=20
> David Spinadel (2):
>       iwlwifi: mvm: notify sched scan complete from stop routine
>       iwlwifi: mvm: stop sched scan before association
>=20
> Eliad Peller (2):
>       iwlwifi: mvm: wait for d0i3 exit in some more ampdu actions
>       iwlwifi: mvm: set SKIP_OVER_DTIM flag only if needed
>=20
> Emmanuel Grumbach (18):
>       Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-ne=
xt
>       Merge remote-tracking branch 'wireless-next/master' into iwlwifi-ne=
xt
>       iwlwifi: mvm: implement mac80211's flush callback
>       iwlwifi: mvm: fix sparse warning when _DEBUGFS isn't set
>       iwlwifi: dvm: don't use _ni mac80211's callbacks
>       iwlwifi: pcie: try to get ownership several times
>       Merge remote-tracking branch 'iwlwifi-fixes/master' into HEAD
>       iwlwifi: remove CMD_SYNC
>       iwlwifi: pcie: disable BHs in iwl_pcie_txq_check_wrptrs
>       iwlwifi: mvm: BT Coex - fix boost register / LUT values
>       iwlwifi: mvm: BT Coex - send channel inhibition before association
>       iwlwifi: mvm: don't allow diversity if BT Coex / TT forbid it
>       iwlwifi: mvm: disable beacon filtering
>       Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-ne=
xt
>       iwlwifi: mvm: disable reduced Tx power when not applicable
>       iwlwifi: mvm: remove debugfs hook for reduced tx power
>       iwlwifi: mvm: make iwl_mvm_update_beacon_abort static
>       cfg80211: allow RSSI compensation
>=20
> Eran Harary (9):
>       iwlwifi: mvm: fix bug with OTP memory size
>       iwlwifi: mvm: prevent nic to powered up at driver load
>       iwlwifi: mvm: Prioritize external nvm values on top of the OTP valu=
es
>       iwlwifi: mvm: select the MAC address according to priority
>       iwlwifi: mvm: fix bug in parse_nvm_sections
>       iwlwifi: 8000: add default NVM file name in family 8000
>       iwlwifi: mvm: add channel 14 to the low band list
>       iwlwifi: mvm: revisit the NVM handling code
>       iwlwifi: allow dynamic configuration of internal memory
>=20
> Eyal Shapira (6):
>       iwlwifi: mvm: rs: revert changes to search cycle rules
>       iwlwifi: mvm: rs: overhaul rs_get_best_rate
>       iwlwifi: mvm: rs: don't allow TPC when power save is disabled
>       iwlwifi: mvm: rs: avoid TPC while in search cycle
>       iwlwifi: mvm: rs: choose correct expected tpt table
>       iwlwifi: mvm: rs: enable MCS9 for Tx
>=20
> Felix Fietkau (2):
>       ath9k_hw: get QCA953x WMAC revision via platform_data
>       cfg80211: allow restricting supported dfs regions
>=20
> George Spelvin (3):
>       lib/crc7: Shift crc7() output left 1 bit
>       drivers/mmc/host/mmc_spi.c: Use get/put_unaligned_be32
>       drivers/net/wireless/ti/wl*/spi.c: Simplify CRC computation
>=20
> Grazvydas Ignotas (4):
>       Revert "wl1251: enforce changed hw encryption support on monitor st=
ate change"
>       wl1251: fix null data for IBSS
>       wl1251: fix mixed up args for join
>       wl1251: only call ieee80211_beacon_loss in managed mode
>=20
> Hante Meuleman (3):
>       brcmfmac: Move out hdrpull from tx_finalize.
>       brcmfmac: Move handling 802.1x frames to dhd_linux.
>       brcmfmac: Make FWS queueing configurable.
>=20
> Heikki Krogerus (5):
>       ARM: tegra: remove obsolete gpio entries
>       net: rfkill: gpio: remove unused and obsolete platform parameters
>       net: rfkill: gpio: add ACPI ID for GPS module on Lenovo Miix2
>       net: rfkill: gpio: add ACPI IDs for a Broadcom bluetooth chip
>       net: rfkill: gpio: hard-code the gpio names
>=20
> Helmut Schaa (2):
>       ath9k: Allow platform override without EEPROM override
>       amend "ath9k: Allow platform override without EEPROM override"
>=20
> Hiren Tandel (3):
>       NFC: NCI: No need to reverse ATR_RES Response
>       NFC: Add RAW socket type support for SOCKPROTO_RAW
>       NFC: NCI: Send all NCI frames to raw sockets
>=20
> Jahnavi Meher (1):
>       rsi: Changed the return value to enable BA set-up
>=20
> Janusz Dziedzic (3):
>       cfg80211: fix start_radar_detection issue
>       ath: add DFS FCC pattern detector
>       ath: add JP DFS pattern detector
>=20
> Joe Perches (1):
>       wlcore: Remove trailing semicolon from do {...} while (0) macro
>=20
> Johannes Berg (18):
>       cfg80211: remove BUG_ON usage
>       mac80211: remove BUG_ON usage
>       mac80211: mark local variable __maybe_unused
>       iwlwifi: mvm: remove useless variable
>       iwlwifi: make LED support optional
>       iwlwifi: pcie: use bool for iwl_pcie_txq_build_tfd() argument
>       iwlwifi: pcie: get rid of q->n_bd
>       iwlwifi: mvm/pcie: capture last commands on firmware error
>       mac80211: handle failed restart/resume better
>       iwlwifi: add missing trailing newlines to debug messages
>       iwlwifi: cause build error on missing newline
>       iwlwifi: remove spurious newline in Kconfig
>       iwlwifi: mvm: enable RX chain diversity if needed
>       iwlwifi: fix LED support Kconfig dependencies
>       mac80211: minstrel-ht: small clarifications
>       cfg80211: constify MAC addresses in cfg80211 ops
>       cfg80211: constify more pointers in the cfg80211 API
>       cfg80211: constify wowlan/coalesce mask/pattern pointers
>=20
> John W. Linville (14):
>       Merge branch 'rfkill-gpio-cleanups' of git://git.kernel.org/.../jbe=
rg/mac80211-next
>       Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi=
-next
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless
>       Merge branch 'for-linville' of git://github.com/kvalo/ath
>       Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
>       Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetoo=
th
>       ath9k: fixup "ath9k_htc: fix build with disabled debug"
>       Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi=
-fixes
>       Merge tag 'nfc-next-3.16-1' of git://git.kernel.org/.../sameo/nfc-n=
ext
>       Merge git://git.kernel.org/.../jberg/mac80211-next
>       Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi=
-next
>       mwifiex: use 'const' qualifier for 2nd arg of mwifiex_tdls_add_ht_o=
per
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless=
-next into for-davem
>=20
> Julia Lawall (1):
>       brcmsmac: make return of 0 explicit
>=20
> Liad Kaufman (2):
>       iwlwifi: use dev_printk instead of dev_dbg for debug logs
>       iwlwifi: update nmi register
>=20
> Loic Poulain (1):
>       rfkill-gpio: Use gpio cansleep version
>=20
> Luciano Coelho (10):
>       cfg80211: fix docbook warning
>       mac80211: fix sparse warning caused by __ieee80211_channel_switch()
>       cfg80211: pass the actual iftype when calling cfg80211_chandef_dfs_=
required()
>       iwlwifi: mvm: combine p2p and station mac context functions
>       cfg80211: add documentation for max_num_csa_counters
>       mac80211: fix csa_counter_offs argument name in docbook
>       iwlwifi: mvm: update power after phy_ctxt is NULL when unassigning =
chanctx
>       iwlwifi: mvm: enable MAC_FILTER_IN_BEACON when forced_assoc_off is =
set
>       iwlwifi: mvm: set the MAC_FILTER_IN_BEACON flag also for P2P
>       iwlwifi: mvm: pass force_assoc_off all the way down to avoid hacks
>=20
> Mark A. Greer (18):
>       NFC: trf7970a: Increase TRF7970A_WAIT_FOR_RX_DATA_TIMEOUT to 20 ms
>       NFC: trf7970a: Only abort a command if one is active
>       NFC: trf7970a: Clear 'NFC Target Detection Level' register
>       NFC: trf7970a: Reset FIFO when 'End of TX' Interrupt Occurs
>       NFC: trf7970a: Only write 'ISO Control' when its changing
>       NFC: trf7970a: Set 'Modulator and SYS_CLK Control' after 'ISO Contr=
ol'
>       NFC: trf7970a: Allow different Modulator and SYS_CLK Control regist=
er values
>       NFC: trf7970a: Set correct Vin voltage in Chip Status Control regis=
ter
>       NFC: trf7970a: Turn RF on after hardware is configured
>       NFC: trf7970a: Add pm_runtime support
>       NFC: trf7970a: Don't return value from trf7970a_switch_rf_on()
>       NFC: trf7970a: Add 'autosuspend-delay' DTS property
>       NFC: trf7970a: Document the 'autosuspend-delay' DTS property
>       NFC: digital: Add macros for the ISO/IEC 14443-B Protocol
>       NFC: digital: Add support for ISO/IEC 14443-B Protocol
>       NFC: trf7970a: Add support for the ISO/IEC 14443-B and Type 4B tags
>       NFC: digital: SENSF_RES excludes RD when SENSF_REQ RC is zero
>       NFC: digital: Handle multiple SENSF_REQ frames
>=20
> Matt Chen (1):
>       iwlwifi: mvm: add uapsd_disable module parameter
>=20
> Michal Kazior (12):
>       ath10k: differentiate between target init failures
>       ath10k: don't wait for device init if it crashed
>       ath10k: skip suspending when recovering
>       ath10k: make sure to not leak beacon dma mapping
>       ath10k: make sure to not use invalid beacon pointer
>       ath10k: prevent beacon memory leak
>       ath10k: fix firmware recovery with ap interface
>       mac80211: fix CSA tx queue stopping
>       mac80211: split CSA finalize function
>       cfg80211: export interface stopping function
>       mac80211: ignore cqm during csa
>       mac80211: disconnect iface if CSA unexpectedly fails
>=20
> Oleksij Rempel (11):
>       ath9k-common: create common-debug and move modal_eeprom to cmn
>       ath9k_htc: use ath9k_cmn_debug_modal_eeprom
>       ath9k: move base_eeprom debug code to ath9k_cmn_debug_base_eeprom
>       ath9k_htc: use ath9k_cmn_debug_base_eeprom
>       ath9k: reorder or remove some includes
>       ath9k & ath9k_htc: move ath_rx_stats to cmn
>       ath9k: move recv to ath9k_cmn_debug_recv
>       ath9k_htc: use ath9k_cmn_debug_recv
>       ath9k: move phy_err to ath9k_cmn_debug_phy_err
>       ath9k_htc: use ath9k_cmn_debug_phy_err
>       ath9k_htc: fix build with disabled debug
>=20
> Ondrej Zary (1):
>       orinoco_usb: Fix broken firmware load error checking
>=20
> Peter Wu (1):
>       rtlwifi: remove unused allow_all_destaddr functions
>=20
> Rafa=C5=82 Mi=C5=82ecki (14):
>       b43: adjust code to compile without SSB
>       b43: drop SSB dependency
>       b43: split upload of init values into 2 functions
>       b43: move PHY reset code into PHY specific file
>       b43: complete PHY reset
>       b43: rework band switching
>       ssb: sprom: add dev_id field for value overriding standard ID
>       b43: make B43_PCMCIA and B43_SDIO depend on B43_SSB
>       b43: move bands detection to a separated function
>       b43: add more devices to the bands database
>       b43: xmit: set 5 GHz bit depending on current band
>       b43: fix typo in define name for 2 GHz channels (s/CHAN4G/CHAN2G/)
>       b43: fix list of 5 GHz channels for 802.11n cards
>       b43: N-PHY: add missing calib values for radio 0x2026 rev 11
>=20
> Rajkumar Manoharan (4):
>       ath9k: Advertise support for AP mode channel width changes
>       ath9k_hw: Abort transmission for sleeping station
>       ath9k: Handle multiple keys while setting tx filters
>       ath9k: fix sleep timer during suspend
>=20
> Richard Genoud (1):
>       rt2x00: Endless loop on hub port power down
>=20
> Samuel Ortiz (1):
>       Bluetooth: Fix L2CAP LE debugfs entries permissions
>=20
> Zefir Kurtisi (2):
>       ath9k: non-functional: calculate DFS pulse interval per-wiphy
>       ath9k: fix build error with disabled debug
>=20
>  .../devicetree/bindings/net/nfc/pn544.txt          |  35 +
>  .../devicetree/bindings/net/nfc/st21nfca.txt       |  33 +
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |   2 +
>  arch/arm/mach-tegra/board-paz00.c                  |   4 +-
>  arch/mips/bcm47xx/sprom.c                          |   1 +
>  drivers/mmc/host/mmc_spi.c                         |  18 +-
>  drivers/net/wireless/ath/ath10k/core.c             |   6 +-
>  drivers/net/wireless/ath/ath10k/mac.c              |  16 +
>  drivers/net/wireless/ath/ath10k/pci.c              |  18 +-
>  drivers/net/wireless/ath/ath10k/wmi.c              |   2 +
>  drivers/net/wireless/ath/ath6kl/cfg80211.c         |   7 +-
>  drivers/net/wireless/ath/ath6kl/wmi.c              |   2 +-
>  drivers/net/wireless/ath/ath6kl/wmi.h              |   2 +-
>  drivers/net/wireless/ath/ath9k/Makefile            |   3 +-
>  drivers/net/wireless/ath/ath9k/ath9k.h             |   3 +-
>  drivers/net/wireless/ath/ath9k/beacon.c            |   5 +-
>  drivers/net/wireless/ath/ath9k/common-debug.c      | 253 ++++++
>  drivers/net/wireless/ath/ath9k/common-debug.h      |  72 ++
>  drivers/net/wireless/ath/ath9k/common.h            |   1 +
>  drivers/net/wireless/ath/ath9k/debug.c             | 214 +----
>  drivers/net/wireless/ath/ath9k/debug.h             |  44 -
>  drivers/net/wireless/ath/ath9k/dfs.c               |   8 +-
>  drivers/net/wireless/ath/ath9k/dfs_debug.h         |   1 +
>  drivers/net/wireless/ath/ath9k/htc.h               |  19 +-
>  drivers/net/wireless/ath/ath9k/htc_drv_debug.c     | 555 +------------
>  drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   3 +-
>  drivers/net/wireless/ath/ath9k/hw.c                |   3 +-
>  drivers/net/wireless/ath/ath9k/init.c              |   5 +-
>  drivers/net/wireless/ath/ath9k/mac.c               |  22 +
>  drivers/net/wireless/ath/ath9k/mac.h               |   1 +
>  drivers/net/wireless/ath/ath9k/main.c              |  47 +-
>  drivers/net/wireless/ath/ath9k/pci.c               |   3 +-
>  drivers/net/wireless/ath/ath9k/recv.c              |   4 +-
>  drivers/net/wireless/ath/ath9k/reg.h               |   3 -
>  drivers/net/wireless/ath/carl9170/usb.c            |   8 +-
>  drivers/net/wireless/ath/dfs_pattern_detector.c    |  45 +-
>  drivers/net/wireless/ath/wil6210/cfg80211.c        |   4 +-
>  drivers/net/wireless/ath/wil6210/main.c            |   4 +-
>  drivers/net/wireless/ath/wil6210/wil6210.h         |   2 +-
>  drivers/net/wireless/b43/Kconfig                   |  42 +-
>  drivers/net/wireless/b43/bus.h                     |  10 +
>  drivers/net/wireless/b43/main.c                    | 412 ++++-----
>  drivers/net/wireless/b43/phy_common.c              |  85 ++
>  drivers/net/wireless/b43/phy_common.h              |   5 +-
>  drivers/net/wireless/b43/radio_2056.c              | 918 +++++++++++++++=
++++++
>  drivers/net/wireless/b43/xmit.c                    |   2 +-
>  drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   2 +-
>  drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   1 +
>  .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  18 +
>  .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  32 +-
>  .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |  24 +
>  drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  80 +-
>  drivers/net/wireless/brcm80211/brcmfmac/nvram.c    | 220 ++++-
>  drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   1 +
>  .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 206 +++--
>  drivers/net/wireless/brcm80211/brcmsmac/main.c     |  13 +-
>  drivers/net/wireless/brcm80211/brcmutil/d11.c      |  93 ++-
>  drivers/net/wireless/brcm80211/include/brcmu_d11.h |  14 +-
>  .../net/wireless/brcm80211/include/brcmu_wifi.h    |   1 +
>  drivers/net/wireless/iwlwifi/Kconfig               |  13 +-
>  drivers/net/wireless/iwlwifi/dvm/Makefile          |   3 +-
>  drivers/net/wireless/iwlwifi/dvm/calib.c           |   1 -
>  drivers/net/wireless/iwlwifi/dvm/debugfs.c         |   7 +-
>  drivers/net/wireless/iwlwifi/dvm/dev.h             |   2 +
>  drivers/net/wireless/iwlwifi/dvm/devices.c         |   2 -
>  drivers/net/wireless/iwlwifi/dvm/led.h             |  12 +
>  drivers/net/wireless/iwlwifi/dvm/lib.c             |  17 +-
>  drivers/net/wireless/iwlwifi/dvm/main.c            |  27 +-
>  drivers/net/wireless/iwlwifi/dvm/power.c           |   4 +-
>  drivers/net/wireless/iwlwifi/dvm/rs.c              |  10 +-
>  drivers/net/wireless/iwlwifi/dvm/rx.c              |   2 +-
>  drivers/net/wireless/iwlwifi/dvm/rxon.c            |  18 +-
>  drivers/net/wireless/iwlwifi/dvm/scan.c            |   3 +-
>  drivers/net/wireless/iwlwifi/dvm/sta.c             |  29 +-
>  drivers/net/wireless/iwlwifi/dvm/tt.c              |   2 +-
>  drivers/net/wireless/iwlwifi/dvm/tx.c              |  24 +-
>  drivers/net/wireless/iwlwifi/dvm/ucode.c           |   6 +-
>  drivers/net/wireless/iwlwifi/iwl-7000.c            |   2 +-
>  drivers/net/wireless/iwlwifi/iwl-8000.c            |   5 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |   4 +-
>  drivers/net/wireless/iwlwifi/iwl-config.h          |   7 +
>  drivers/net/wireless/iwlwifi/iwl-debug.c           |   6 +-
>  drivers/net/wireless/iwlwifi/iwl-debug.h           |  41 +-
>  drivers/net/wireless/iwlwifi/iwl-drv.c             |   5 +
>  .../{mvm/fw-error-dump.h =3D> iwl-fw-error-dump.h}   |  26 +
>  drivers/net/wireless/iwlwifi/iwl-fw.h              |  10 +-
>  drivers/net/wireless/iwlwifi/iwl-io.c              |  18 +
>  drivers/net/wireless/iwlwifi/iwl-io.h              |   1 +
>  drivers/net/wireless/iwlwifi/iwl-modparams.h       |   1 +
>  drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  50 +-
>  drivers/net/wireless/iwlwifi/iwl-phy-db.c          |   9 +-
>  drivers/net/wireless/iwlwifi/iwl-prph.h            |   3 +
>  drivers/net/wireless/iwlwifi/iwl-trans.h           |  50 +-
>  drivers/net/wireless/iwlwifi/mvm/Makefile          |   3 +-
>  drivers/net/wireless/iwlwifi/mvm/coex.c            |  80 +-
>  drivers/net/wireless/iwlwifi/mvm/d3.c              |  35 +-
>  drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |  48 +-
>  drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  11 +-
>  drivers/net/wireless/iwlwifi/mvm/fw.c              |  19 +-
>  drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        | 114 ++-
>  drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 173 +++-
>  drivers/net/wireless/iwlwifi/mvm/mvm.h             |  34 +-
>  drivers/net/wireless/iwlwifi/mvm/nvm.c             | 102 +--
>  drivers/net/wireless/iwlwifi/mvm/ops.c             |  43 +-
>  drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |  23 +-
>  drivers/net/wireless/iwlwifi/mvm/power.c           | 208 ++---
>  drivers/net/wireless/iwlwifi/mvm/quota.c           |   2 +-
>  drivers/net/wireless/iwlwifi/mvm/rs.c              | 179 ++--
>  drivers/net/wireless/iwlwifi/mvm/scan.c            |  13 +-
>  drivers/net/wireless/iwlwifi/mvm/sta.c             |  18 +-
>  drivers/net/wireless/iwlwifi/mvm/sta.h             |   3 -
>  drivers/net/wireless/iwlwifi/mvm/time-event.c      |   4 +-
>  drivers/net/wireless/iwlwifi/mvm/tt.c              |   1 -
>  drivers/net/wireless/iwlwifi/mvm/tx.c              |   2 +-
>  drivers/net/wireless/iwlwifi/mvm/utils.c           |  41 +-
>  drivers/net/wireless/iwlwifi/pcie/drv.c            |  14 +-
>  drivers/net/wireless/iwlwifi/pcie/internal.h       |  24 +-
>  drivers/net/wireless/iwlwifi/pcie/rx.c             |   2 +-
>  drivers/net/wireless/iwlwifi/pcie/trans.c          |  90 +-
>  drivers/net/wireless/iwlwifi/pcie/tx.c             | 139 ++--
>  drivers/net/wireless/libertas/cfg.c                |   7 +-
>  drivers/net/wireless/libertas/defs.h               |   3 +-
>  drivers/net/wireless/libertas/rx.c                 |   8 +-
>  drivers/net/wireless/mwifiex/11n.c                 |  42 +
>  drivers/net/wireless/mwifiex/11n.h                 |   3 +-
>  drivers/net/wireless/mwifiex/11n_aggr.c            |   7 +
>  drivers/net/wireless/mwifiex/cfg80211.c            |  19 +-
>  drivers/net/wireless/mwifiex/fw.h                  |  23 +-
>  drivers/net/wireless/mwifiex/main.h                |  22 +-
>  drivers/net/wireless/mwifiex/pcie.c                |   1 +
>  drivers/net/wireless/mwifiex/sdio.c                |   6 +-
>  drivers/net/wireless/mwifiex/sta_cmd.c             |   7 +
>  drivers/net/wireless/mwifiex/sta_cmdresp.c         |  18 +-
>  drivers/net/wireless/mwifiex/sta_event.c           |  44 +
>  drivers/net/wireless/mwifiex/sta_rx.c              |  16 +-
>  drivers/net/wireless/mwifiex/sta_tx.c              |   4 +-
>  drivers/net/wireless/mwifiex/tdls.c                |  97 ++-
>  drivers/net/wireless/mwifiex/util.c                |   6 +-
>  drivers/net/wireless/mwifiex/wmm.c                 |  12 +-
>  drivers/net/wireless/mwifiex/wmm.h                 |   5 +-
>  drivers/net/wireless/orinoco/hw.c                  |   4 +-
>  drivers/net/wireless/orinoco/hw.h                  |   4 +-
>  drivers/net/wireless/orinoco/orinoco_usb.c         |   2 +-
>  drivers/net/wireless/orinoco/wext.c                |   4 +-
>  drivers/net/wireless/rndis_wlan.c                  |   4 +-
>  drivers/net/wireless/rsi/rsi_91x_mac80211.c        |   1 +
>  drivers/net/wireless/rt2x00/rt2x00usb.c            |   6 +
>  drivers/net/wireless/rtl818x/rtl8180/dev.c         |  17 +-
>  drivers/net/wireless/rtl818x/rtl8187/dev.c         |  11 +-
>  drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |  20 -
>  drivers/net/wireless/rtlwifi/rtl8188ee/hw.h        |   2 -
>  drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   5 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  21 -
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |   2 -
>  drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   1 -
>  drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   2 +-
>  drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  20 -
>  drivers/net/wireless/rtlwifi/rtl8192se/hw.h        |   2 -
>  drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |   1 -
>  drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |  21 -
>  drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   2 -
>  drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |   1 -
>  drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |  20 -
>  drivers/net/wireless/rtlwifi/rtl8723be/hw.h        |   2 -
>  drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |   5 +-
>  drivers/net/wireless/rtlwifi/wifi.h                |   6 +-
>  drivers/net/wireless/ti/wl1251/acx.c               |   1 -
>  drivers/net/wireless/ti/wl1251/cmd.c               |   1 -
>  drivers/net/wireless/ti/wl1251/event.c             |   5 +-
>  drivers/net/wireless/ti/wl1251/main.c              |  68 +-
>  drivers/net/wireless/ti/wl1251/spi.c               |  44 +-
>  drivers/net/wireless/ti/wlcore/debugfs.h           |   4 +-
>  drivers/net/wireless/ti/wlcore/main.c              |   2 +-
>  drivers/net/wireless/ti/wlcore/spi.c               |  46 +-
>  drivers/net/wireless/ti/wlcore/wlcore_i.h          |   4 +-
>  drivers/nfc/Kconfig                                |   1 +
>  drivers/nfc/Makefile                               |   1 +
>  drivers/nfc/pn544/i2c.c                            | 154 +++-
>  drivers/nfc/st21nfca/Kconfig                       |  23 +
>  drivers/nfc/st21nfca/Makefile                      |   8 +
>  drivers/nfc/st21nfca/i2c.c                         | 724 ++++++++++++++++
>  drivers/nfc/st21nfca/st21nfca.c                    | 698 ++++++++++++++++
>  drivers/nfc/st21nfca/st21nfca.h                    |  87 ++
>  drivers/nfc/trf7970a.c                             | 252 ++++--
>  drivers/staging/wlan-ng/cfg80211.c                 |   4 +-
>  include/linux/ath9k_platform.h                     |   2 +
>  include/linux/crc7.h                               |   8 +-
>  include/linux/platform_data/st21nfca.h             |  32 +
>  include/linux/rfkill-gpio.h                        |  10 -
>  include/linux/ssb/ssb.h                            |   1 +
>  include/net/cfg80211.h                             | 191 +++--
>  include/net/mac80211.h                             |  78 +-
>  include/net/nfc/digital.h                          |   4 +
>  include/net/nfc/hci.h                              |   1 +
>  include/net/nfc/nfc.h                              |   3 +
>  include/uapi/linux/nfc.h                           |  16 +-
>  include/uapi/linux/nl80211.h                       |  25 +-
>  lib/crc7.c                                         |  84 +-
>  net/bluetooth/l2cap_core.c                         |   4 +-
>  net/mac80211/Makefile                              |   3 +-
>  net/mac80211/cfg.c                                 | 538 ++++--------
>  net/mac80211/chan.c                                |   4 +-
>  net/mac80211/driver-ops.h                          | 121 ++-
>  net/mac80211/ibss.c                                |   2 +-
>  net/mac80211/ieee80211_i.h                         |  17 +-
>  net/mac80211/iface.c                               |   7 +
>  net/mac80211/key.c                                 |   7 +-
>  net/mac80211/main.c                                |   2 +
>  net/mac80211/mesh.c                                |   2 +-
>  net/mac80211/mesh_pathtbl.c                        |   6 +-
>  net/mac80211/mesh_sync.c                           |   2 +-
>  net/mac80211/mlme.c                                |  46 +-
>  net/mac80211/rc80211_minstrel.c                    |  12 +
>  net/mac80211/rc80211_minstrel_ht.c                 |  22 +-
>  net/mac80211/scan.c                                |  15 +-
>  net/mac80211/tdls.c                                | 325 ++++++++
>  net/mac80211/trace.h                               |  32 +
>  net/mac80211/tx.c                                  | 189 +++--
>  net/mac80211/util.c                                |  46 +-
>  net/nfc/digital.h                                  |   1 +
>  net/nfc/digital_core.c                             |  20 +-
>  net/nfc/digital_technology.c                       | 230 +++++-
>  net/nfc/hci/command.c                              |   6 +-
>  net/nfc/hci/core.c                                 |  47 +-
>  net/nfc/llcp_commands.c                            |   2 +-
>  net/nfc/llcp_core.c                                |  11 +-
>  net/nfc/nci/core.c                                 |   9 +
>  net/nfc/nci/ntf.c                                  |   7 +-
>  net/nfc/nfc.h                                      |   6 +
>  net/nfc/rawsock.c                                  |  94 ++-
>  net/rfkill/rfkill-gpio.c                           |  59 +-
>  net/wireless/ap.c                                  |   4 +-
>  net/wireless/chan.c                                |   5 +-
>  net/wireless/core.c                                |  67 +-
>  net/wireless/core.h                                |   7 +
>  net/wireless/ibss.c                                |   2 +-
>  net/wireless/mesh.c                                |   4 +-
>  net/wireless/nl80211.c                             | 140 +++-
>  net/wireless/rdev-ops.h                            |   2 +-
>  net/wireless/reg.c                                 |   3 +-
>  net/wireless/scan.c                                |  12 +-
>  net/wireless/sme.c                                 |   8 +-
>  net/wireless/trace.h                               |  37 +-
>  net/wireless/util.c                                |  38 +-
>  244 files changed, 7662 insertions(+), 3181 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/nfc/pn544.txt
>  create mode 100644 Documentation/devicetree/bindings/net/nfc/st21nfca.txt
>  create mode 100644 drivers/net/wireless/ath/ath9k/common-debug.c
>  create mode 100644 drivers/net/wireless/ath/ath9k/common-debug.h
>  rename drivers/net/wireless/iwlwifi/{mvm/fw-error-dump.h =3D> iwl-fw-err=
or-dump.h} (84%)
>  create mode 100644 drivers/nfc/st21nfca/Kconfig
>  create mode 100644 drivers/nfc/st21nfca/Makefile
>  create mode 100644 drivers/nfc/st21nfca/i2c.c
>  create mode 100644 drivers/nfc/st21nfca/st21nfca.c
>  create mode 100644 drivers/nfc/st21nfca/st21nfca.h
>  create mode 100644 include/linux/platform_data/st21nfca.h
>  create mode 100644 net/mac80211/tdls.c
> --=20
> John W. Linville		Someday the world will need a hero, and you
> linville@tuxdriver.com			might be all we have.  Be ready.



--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ftEhullJWpWg/VHq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJThNccAAoJEJctW/TcYTgGBhUP/jeL4U8xDIx34j4l75HjDxSj
eDPgcXmEmbiEtm3ows/7QNzRI/daGMgf0ShgFsYc6hUJv8vuax0ao6npT71VDV8x
2/lfPmUOOCsOeLqL0rEposLsRL1cA9rvIMt+FhNaYTWezbXu+ijozt/M2ShOOmtm
RCEwWldRi0s1mgkQMYxsBSdvaeibN/SkRlbJv7YJvxykxhTnznSs5V6XAj0Voa7I
IlB2LwYRWpzKyCar1gFOXVdtEo2gJbTngx1t4RzM+lDK2ym3Y1zyBRjA8WYErpEJ
xhbT7j+djKFevtK/tj3loDFIuMfrU02hpdId7+lXaZvMeSZ5e6VPh5EU7Vw/r/X/
7qx/jEKQCQC9sryCoDv3bcdZCB7RAIaEgInLAct8osYEbMY5WTOtSGjFtE3E5dwS
JWo1PJw9/Nia1jjeFHMERGtGvRcFvWKdikanxT90NU18989zKg2UHpBeMRk/7Wvw
YaiuX3B2qsVG7prQ7L6Sj7W2JhGOCFaGuRNOyAP6KnfDkKZymRxQwNheTc+jqvax
X6dnMA1pbR2VcuirMsiq7Bt/4nRtNoJeC8KOxb9NU9/vaCQFDU88C5ldj4VdVW4+
bNpKJ3yAv7goq5Y01Xz8x6ixv4UdSDE6QAtpzggd0cfSoe9aw6BQ/uzkZMYaPqEz
3U/2GliWUfCy/EcA8fc9
=wtp1
-----END PGP SIGNATURE-----

--ftEhullJWpWg/VHq--
