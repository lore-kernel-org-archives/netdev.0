From: Reinoud Koornstra <reinoudkoornstra@gmail.com>
Subject: Re: pull-request: wireless-drivers-next 2016-05-13 (take two)
Date: Thu, 19 May 2016 16:20:42 -0600
Message-ID: <CAAA5faH9wt3AU=aJLPh=ksg3+s7YwSwuh7_mYJ734yd3tuRTQg@mail.gmail.com>
References: <87eg8yfc8b.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35396 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbcESWUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 18:20:44 -0400
In-Reply-To: <87eg8yfc8b.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 6:45 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Hi Dave,
>
> this the second version of the last pull request to net-next for 4.7,
> which got postponed due to the recent iwlwifi merge conflict. Now that
> Linus fixed the merge problem in his tree I actually didn't have to fix
> anything in my tree anymore. So that's why I still use the same tag as
> in my previous pull request.
>
> The only dependency is that you need Linus' iwlwifi fix in your tree
> before you pull this:
>
> 0e034f5c4bc4 iwlwifi: fix mis-merge that breaks the driver
>
> So if you could pull latest Linus' tree to net-next that would solve
> that. I just did a test merge of that on your net-next tree and didn't
> see any conflicts, so this pull should go smoothly. Also these patches
> have been in linux-next at least a week now. But please let me know if
> you see any issues.
>
> And I think a lesson learned from this is that I need to immediately
> merge wireless-drivers to wireless-drivers-next if there are any
> conflicts between the trees. Or how do you suggest to handle cases like
> that?
>
> Kalle
>
>
> The following changes since commit ede00a5ceb4d903a8c137a52bb77d574baaef8bd:
>
>   Merge tag 'wireless-drivers-next-for-davem-2016-05-02' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next (2016-05-03 00:35:16 -0400)
>
> are available in the git repository at:
>
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-05-13
>
> for you to fetch changes up to 52776a700b53969345a3cc5daed1c797d016a188:
>
>   Merge ath-next from ath.git (2016-05-11 23:23:51 +0300)
>
> ----------------------------------------------------------------
>
> wireless-drivers patches for 4.7
>
> Major changes:
>
> iwlwifi
>
> * remove IWLWIFI_DEBUG_EXPERIMENTAL_UCODE kconfig option
> * work for RX multiqueue continues
> * dynamic queue allocation work continues
> * add Luca as maintainer
> * a bunch of fixes and improvements all over

Can you let me know when this is merged in 4.6+, then I'll try it right away.
Thanks,

Reinoud.

>
> brcmfmac
>
> * add 4356 sdio support
>
> ath6kl
>
> * add ability to set debug uart baud rate with a module parameter
>
> wil6210
>
> * add debugfs file to configure firmware led functionality
>
> ----------------------------------------------------------------
> Alan Liu (1):
>       ath10k: add max_tx_power for QCA6174 WLAN.RM.2.0 firmware
>
> Anilkumar Kolli (1):
>       ath10k: fix kernel panic, move arvifs list head init before htt init
>
> Bjorn Andersson (1):
>       wcn36xx: Set SMD timeout to 10 seconds
>
> Christian Daudt (1):
>       brcmfmac: Add 4356 sdio support
>
> Dan Carpenter (3):
>       rtlwifi: rtl818x: silence uninitialized variable warning
>       airo: prevent potential underflow in airo_set_freq()
>       atmel: potential underflow in atmel_set_freq()
>
> Denys Vlasenko (1):
>       rtlwifi: rtl818x: Deinline indexed IO functions, save 21568 bytes
>
> Emmanuel Grumbach (5):
>       iwlwifi: mvm: don't override the rate with the AMSDU len
>       iwlwifi: mvm: allow a debug knob for Tx A-MSDU even if rate control forbids it
>       iwlwifi: remove IWLWIFI_DEBUG_EXPERIMENTAL_UCODE
>       iwlwifi: don't access a nonexistent register upon assert
>       iwlwifi: add default value to disable_11ac mod param description
>
> Golan Ben-Ami (1):
>       iwlwifi: mvm: add more registers to dump upon error
>
> Gregory Greenman (2):
>       iwlwifi: consider VHT 160MHz while parsing NVM
>       iwlwifi: turn on SGI support for VHT 160MHz
>
> Guy Mishol (1):
>       wlcore/wl12xx: Fix fw logger over sdio
>
> Haim Dreyfuss (4):
>       iwlwifi: Rename 9560 to 9260 and add new PCI IDs for it
>       iwlwifi: allow combining different phy images with mac images
>       iwlwifi: Fix firmware name maximum length definition
>       iwlwifi: pcie: don't wake up the NIC when writing CSRs in MSIX mode
>
> Helmut Schaa (4):
>       ath9k: reuse ar9003_hw_tx_power_regwrite for tx99 setup
>       ath9k: Move TX99 config option under ath9k debugging
>       ath9k: Simplify ar9003_hw_tx99_set_txpower
>       ath9k: Fix symbol overlap window for half/quarter channels
>
> Jes Sorensen (11):
>       rtl8xxxu: Rename rtl8xxxu.c to rtl8xxxu_core.c
>       rtl8xxxu: move rtl8192e related code into rtl8xxxu_8192e.c
>       rtl8xxxu: move rtl8723b related code into rtl8xxxu_8723b.c
>       rtl8xxxu: move rtl8723a related code into rtl8xxxu_8723a.c
>       rtl8xxxu: move rtl8188[cr] and rtl8192c related code into rtl8xxxu_8192c.c
>       rtl8xxxu: Rename rtl8723a_stop_tx_beacon() to rtl8xxxu_stop_tx_beacon()
>       rtl8xxxu: rename rtl8723a_channel_group() to rtl8xxxu_gen1_channel_to_group()
>       rtl8xxxu: Rename rtl8723a_disabled_to_emu() to rtl8xxxu_disabled_to_emu()
>       rtl8xxxu: Split rtl8723a_h2c_cmd() into a gen1 and a gen2 version
>       rtl8xxxu: rtl8xxxu_prepare_calibrate() is never used on gen1
>       rtl8xxxu: Remove the now obsolete mbox_ext_reg info from rtl8xxxu_fileops
>
> Johannes Berg (7):
>       ath10k: remove VHT capabilities from 2.4GHz
>       iwlwifi: mvm: add firmware API name comment
>       iwlwifi: mvm: advertise RSS queue usage
>       iwlwifi: mvm: pass station to mac80211 RX where known
>       iwlwifi: make configuration structs smaller
>       iwlwifi: pcie: extend device reset delay
>       iwlwifi: pcie: avoid msleep() with short timeout
>
> Julia Lawall (1):
>       rtlwifi: rtl818x: constify rtl_intf_ops structures
>
> Kalle Valo (2):
>       Merge tag 'iwlwifi-next-for-kalle-2016-05-10' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
>       Merge ath-next from ath.git
>
> Liad Kaufman (4):
>       iwlwifi: mvm: allocate queue for probe response in dqa mode
>       iwlwifi: mvm: support p2p device frames tx on dqa queue #2
>       iwlwifi: mvm: support queue removal in ADD_STA hcmd
>       iwlwifi: mvm: support dqa-mode agg on non-shared queue
>
> Lior David (1):
>       wil6210: support regular scan on P2P_DEVICE interface
>
> Luca Coelho (6):
>       Merge tag 'mac80211-next-for-davem-2016-04-13' of git://git.kernel.org/.../jberg/mac80211-next into master
>       Merge tag 'iwlwifi-for-kalle-2016-05-04' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
>       iwlwifi: trans: don't call the trans-specific ref/unref directly
>       iwlwifi: wake from runtime suspend before sending sync commands
>       iwlwifi: mvm: add a new mvm reference type for RX data
>       MAINTAINERS: add myself as co-maintainer of the iwlwifi driver
>
> Lukas Wunner (1):
>       mwifiex: Drop unnecessary include pcieport_if.h
>
> Maya Erez (6):
>       wil6210: add function name to wil log macros
>       wil6210: change RX_HTRSH interrupt print level to debug
>       wil6210: print debug message when transmitting while disconnected
>       wil6210: unmask RX_HTRSH interrupt only when connected
>       wil6210: prevent deep sleep of 60G device in critical paths
>       wil6210: add support for device led configuration
>
> Mohammed Shafi Shajakhan (2):
>       ath10k: fix a typo in ath10k_start()
>       ath10k: move spectral related structures under ath10k debugfs
>
> Mordechai Goodstein (1):
>       iwlwifi: Edit the 8265 SDIO ID
>
> Rajkumar Manoharan (5):
>       ath10k: add pdev bss channel info wmi definitions
>       ath10k: implement wmi_pdev_bss_chan_info_request
>       ath10k: handle pdev_chan_info wmi event
>       ath10k: update bss channel survey information
>       ath10k: release pre_cal_file while unloading driver
>
> Sara Sharon (15):
>       iwlwifi: mvm: implement driver RX queues sync command
>       iwlwifi: mvm: change RX sync notification to be an attribute and not a type
>       iwlwifi: mvm: add infrastructure for tracking BA session in driver
>       iwlwifi: mvm: add reorder buffer per queue
>       iwlwifi: mvm: add reorder timeout per frame
>       iwlwifi: mvm: utilize the frame release infrastructure
>       iwlwifi: mvm: add a flag to disable checksum
>       iwlwifi: mvm: don't allow negative reference count
>       iwlwifi: mvm: loosen nssn comparison to reorder buffer head
>       iwlwifi: mvm: set correct vht capability
>       iwlwifi: mvm: make phy_db size dynamic
>       iwlwifi: mvm: remove redundant alloc_ctx parameter
>       iwlwifi: mvm: use helpers to get iwl_mvm_sta
>       iwlwifi: pcie: use shadow registers for updating write pointer
>       iwlwifi: pcie: grab NIC access only once on RX init
>
> Shengzhen Li (1):
>       mwifiex: change sleep cookie poll count
>
> Steve deRosier (2):
>       ath6kl: fix missing uart debug pin for 6004 HW 3.0
>       ath6kl: add ability to set debug uart baud rate
>
> Vasanthakumar Thiagarajan (2):
>       ath10k: suppress warnings when getting wmi peer_rate_code_list event
>       ath10k: Fix survey reporting with QCA4019
>
> Wei-Ning Huang (1):
>       mwifiex: fixup error messages
>
> wang yanqing (3):
>       rtlwifi: Fix logic error in enter/exit power-save mode
>       rtlwifi: Remove double check for cnt_after_linked
>       rtlwifi: pci: use dev_kfree_skb_irq instead of kfree_skb in rtl_pci_reset_trx_ring
>
>  MAINTAINERS                                        |    1 +
>  drivers/net/wireless/ath/ath10k/core.c             |   18 +-
>  drivers/net/wireless/ath/ath10k/core.h             |    4 +-
>  drivers/net/wireless/ath/ath10k/mac.c              |   40 +-
>  drivers/net/wireless/ath/ath10k/wmi-ops.h          |   21 +
>  drivers/net/wireless/ath/ath10k/wmi.c              |   88 +-
>  drivers/net/wireless/ath/ath10k/wmi.h              |   26 +
>  drivers/net/wireless/ath/ath6kl/core.c             |    3 +
>  drivers/net/wireless/ath/ath6kl/core.h             |    1 +
>  drivers/net/wireless/ath/ath6kl/init.c             |    9 +
>  drivers/net/wireless/ath/ath9k/Kconfig             |   40 +-
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    1 +
>  drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   72 +-
>  drivers/net/wireless/ath/wcn36xx/smd.h             |    2 +-
>  drivers/net/wireless/ath/wil6210/cfg80211.c        |    5 +-
>  drivers/net/wireless/ath/wil6210/debug.c           |   22 +-
>  drivers/net/wireless/ath/wil6210/debugfs.c         |  137 +-
>  drivers/net/wireless/ath/wil6210/interrupt.c       |   93 +-
>  drivers/net/wireless/ath/wil6210/main.c            |   95 +-
>  drivers/net/wireless/ath/wil6210/p2p.c             |    6 +
>  drivers/net/wireless/ath/wil6210/txrx.c            |    2 +-
>  drivers/net/wireless/ath/wil6210/wil6210.h         |   67 +-
>  drivers/net/wireless/ath/wil6210/wmi.c             |   97 +-
>  drivers/net/wireless/ath/wil6210/wmi.h             |   61 +
>  drivers/net/wireless/atmel/atmel.c                 |    2 +-
>  .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |    1 +
>  .../wireless/broadcom/brcm80211/brcmfmac/chip.c    |    1 +
>  .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    4 +-
>  drivers/net/wireless/cisco/airo.c                  |    2 +-
>  drivers/net/wireless/intel/iwlwifi/Kconfig         |    6 -
>  drivers/net/wireless/intel/iwlwifi/iwl-1000.c      |    2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-2000.c      |    2 -
>  drivers/net/wireless/intel/iwlwifi/iwl-5000.c      |    2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-6000.c      |    3 -
>  drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |    1 -
>  drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   17 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   34 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-config.h    |  122 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |   15 +
>  drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   52 +-
>  .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.h  |    1 +
>  drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |    3 +
>  drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |   16 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c    |   68 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-phy-db.h    |    4 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |    2 +
>  drivers/net/wireless/intel/iwlwifi/mvm/constants.h |    1 +
>  drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |    8 +-
>  .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |    9 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |    2 +
>  drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h |    2 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |    9 +-
>  .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |   10 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |    5 +
>  drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |   66 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |    4 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   22 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   74 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  106 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   21 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   26 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  356 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  410 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   13 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |    8 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  134 +-
>  drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   45 +-
>  drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   41 +-
>  drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    3 -
>  drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |  111 +-
>  drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   29 +-
>  drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   21 +-
>  drivers/net/wireless/marvell/mwifiex/pcie.h        |    3 +-
>  drivers/net/wireless/marvell/mwifiex/sdio.c        |    5 +-
>  .../net/wireless/realtek/rtl818x/rtl8187/rtl8187.h |   99 +-
>  .../net/wireless/realtek/rtl818x/rtl8187/rtl8225.c |   93 +
>  drivers/net/wireless/realtek/rtl8xxxu/Makefile     |    3 +
>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |   81 +-
>  .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192c.c |  586 +++
>  .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 1525 ++++++
>  .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723a.c |  397 ++
>  .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c | 1682 ++++++
>  .../rtl8xxxu/{rtl8xxxu.c => rtl8xxxu_core.c}       | 5334 +++-----------------
>  drivers/net/wireless/realtek/rtlwifi/base.c        |    4 +-
>  drivers/net/wireless/realtek/rtlwifi/pci.c         |    4 +-
>  drivers/net/wireless/realtek/rtlwifi/pci.h         |    2 +-
>  drivers/net/wireless/realtek/rtlwifi/ps.c          |   12 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192se/rf.c    |    3 +-
>  drivers/net/wireless/realtek/rtlwifi/usb.c         |    2 +-
>  drivers/net/wireless/realtek/rtlwifi/wifi.h        |    2 +-
>  drivers/net/wireless/ti/wl12xx/main.c              |    4 +-
>  drivers/net/wireless/ti/wlcore/io.c                |   17 +-
>  drivers/net/wireless/ti/wlcore/io.h                |    3 +-
>  include/linux/mmc/sdio_ids.h                       |    1 +
>  95 files changed, 7335 insertions(+), 5336 deletions(-)
>  create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192c.c
>  create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
>  create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723a.c
>  create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c
>  rename drivers/net/wireless/realtek/rtl8xxxu/{rtl8xxxu.c => rtl8xxxu_core.c} (56%)
>
> --
> Kalle Valo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
