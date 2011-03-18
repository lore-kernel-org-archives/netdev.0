From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: [ANN] Compat-wireless for 2.6.38 - vanilla and cherry pick releases
Date: Thu, 17 Mar 2011 18:22:32 -0700
Message-ID: <AANLkTik9eFB4+qYOV9fzGC1vgKEWCOC5+67USe0_aj8E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41716 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab1CRBWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 21:22:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The juicy URLs:

http://wireless.kernel.org/en/users/Download/stable

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/compat-wireless-2.6.38-3.tar.bz2
sha1sum: f1fb354dc2c4a8788bcd65b0e3105d58094450d8

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/compat-wireless-2.6.38-3-ns.tar.bz2
sha1sum: 305e5c7e24246d082f88ffa1c7ad219db1138058

ChangeLog:

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/ChangeLog-2.6.38-wireless

I've only test compiled so far against 2.6.35 the entire tarball and
only load tested against iwlagn.

The boring verbiage:

Linus moved on with life and released 2.6.38, we get to do the same
now with our backported BT, 802.11 and networking components down to
the latest supported kernel listed on kernel.org (sometimes even
further). We get two releases, a vanilla release and a secondary
release that has patches sucked out from linux-next.git which are
pending to be propagated into 2.6.38.1 and also a select few cherry
picked patches from linux-next.git which are not stable material but
have been reported to help with stability.

The pending-stable stuff sucked out from linux-next.git :

mcgrof@tux ~/devel/compat-wireless-2.6 (git::linux-2.6.38.y)$ ls -1
pending-stable/
0001-ath9k_hw-Fix-incorrect-macversion-and-macrev-checks.patch
0002-ath9k_hw-read-and-backup-AR_WA-register-value-even-b.patch
0004-rtl8187-Change-rate-control-feedback.patch
0005-ath9k-remove-support-for-the-FIF_PROMISC_IN_BSS-filt.patch

The cherry picked stuff from linux-next.git :

mcgrof@tux ~/devel/compat-wireless-2.6 (git::linux-2.6.38.y)$ ls -1
linux-next-cherry-picks/
0001a-ath9k_hw-Add-a-function-to-read-sqsum_dvc.patch
0001b-ath9k-Fix-a-PLL-hang-issue-observed-with-AR9485.patch
0001c-ath9k-Cancel-pll_work-while-disabling-radio.patch
0002-ath9k-Fix-incorrect-GPIO-LED-pin-for-AR9485.patch
0003-ath9k_hw-Read-noise-floor-only-for-available-chains-.patch
0004-ath9k_hw-Improve-idle-power-consumption-for-AR9485.patch
0005-ath9k_hw-Increase-the-wait-count-for-nf-load.patch
0006-ath9k_hw-fix-REG_SET_BIT-and-REG_CLR_BIT-for-multipl.patch
0007-ath9k-fix-stopping-tx-dma-on-reset.patch
0008-ath9k-disable-beaconing-before-stopping-beacon-queue.patch
0009-ath9k-improve-reliability-of-beacon-transmission-and.patch
0010-ath9k-fix-aggregation-related-interoperability-issue.patch
0011-staging-Fix-some-incorrect-use-of-positive-error-cod.patch
0012-staging-ath6kl-Fixing-a-NULL-pointer-exception.patch
0013-staging-ath6kl-Fixing-key-settings-for-WPA-WPA2.patch
0014-staging-ath6kl-Return-correct-scan-complete-status.patch
0015-staging-ath6kl-Fixing-target-crash-due-to-mismatch-c.patch
0016-staging-ath6kl-Fixing-driver-initialization-for-manu.patch
0017-staging-ath6kl-Consolidating-hardware-configuration.patch
0018-staging-ath6kl-Adding-support-for-txop-bursting-enab.patch
0019-staging-ath6kl-Fixing-a-memory-leak.patch
0020-staging-ath6kl-Fixing-a-memory-leak.patch
0021-staging-ath6kl-Add-configuration-for-excessive-TX-re.patch
0022-staging-ath6kl-Fixing-memory-leak.patch
0023-staging-ath6kl-Fixing-the-cached-copy-of-the-BSS-fil.patch
0024-staging-ath6kl-Adding-state-in-driver-to-track-the-s.patch
0025-staging-ath6kl-Fixing-accidental-overwriting-of-prob.patch
0026-staging-ath6kl-Fixing-disappearing-of-scan-list-due-.patch
0027-staging-ath6kl-buffer-overflow-in-SEND_FRAME-ioctl.patch
0028-staging-ath6kl-Eliminate-cfg80211-warnings.patch

A lot of these patches have required a manual backport so feel free to
reuse elsewhere if you find useful.

Below is the compat.git and compat-wireless ChangeLog, for more details visit:

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/ChangeLog-2.6.38-wireless


===============================================
ChangeLog for compat-wireless for linux-2.6.38
===============================================

This is the ChangeLog for the Linux kernel project compat-wireless.
It provides a backport of a few Linux kernel subsystems down to
older kernels:

  * 802.11
  * Bluetooth
  * Ethernet

For more details refer to the home page:

http://wireless.kernel.org/en/users/Download/stable/

The compat-wireless project consists of code from three projects:

  * The Linux kernel: linux-2.6-allstable.git
  * Compat-wirelesS: compat-wireless.git
  * Compat: compat.git

The compat-wireless stable releases incorporates code from from
each of these git trees for the respective upstream Linux kernel
stable release. A branch called linux-2.6.3x.y exists for each
stable release. Below we provide the ChangeLog of changes from
the previous branched release to the new branched release.

Release: linux-2.6.38


Updates from the compat.git project:
====================================

git shortlog linux-2.6.37.y..linux-2.6.38.y

Felix Fietkau (6):
      compat: backport pm_qos_*_request
      compat: backport pm_qos_request
      compat: add a wrapper for rfkill.h
      compat: fix pm_qos_params compile error on 2.6.35
      compat: fix a typo in pm_qos_update_request for 2.6.35
      compat: backport LED class software blinking

Hauke Mehrtens (16):
      compat: add missing pm_runtime.h
      compat: backport Generic exponentially weighted moving average (EWMA)
      compat: update wireless.h with new version from linux-next
      compat: backport pr_warn
      compat: fix build with CONFIG_LEDS_CLASS=m
      compat: fix build for kernel <= 2.6.29
      compat: backport skb_checksum_start_offset
      compat backport no_printk
      compat: backport pci_is_pcie and pci_pcie_cap
      compat: backport pci_wake_from_d3
      compat: backport alloc_workqueue
      compat: add generic functions for suspend/resume
      compat: backport kfifo
      compat: backport alloc_ordered_workqueue
      compat: add support for kernel 2.6.38
      compat: backport tty_{lock,unlock,locked}

Johannes Berg (3):
      Felix's patch backported my software blink emulation,     but if
the kernel is 2.6.25 or newer we can also try     the HW offload
first.
      Signed-off-by: Johannes Berg <johannes.berg@intel.com>
      This has disappeared upstream and is no longer used.

Luis R. Rodriguez (3):
      compat: backport sign_extend32()
      compat: backport PCI_EXP_LNKCTL_ES added for on 2.6.29
      compat: add check for CONFIG_COMPAT_KFIFO=m

Updates from the compat-wireless.git project:
=============================================

git shortlog linux-2.6.37.y..linux-2.6.38.y

Dave Vasilevsky (1):
      compat-wireless: Rename config option to CONFIG_B43_PHY_N

Felix Fietkau (1):
      compat-wireless: remove unnecessary chunks from the rfkill patch

Greg Whiteley (1):
      compat-wireless: rt2800pci (and rt2x00pci) don't unload on 'make unload'

Hauke Mehrtens (33):
      compat-wireless: make patches apply again
      compat-wireless: Backport pci power management
      compat-wireless: make patches apply again
      compat-wireless: fix compile error with iwl
      compat-wireless: add missing rename for CONFIG_IWL4965
      compat-wireless: WL1251_SDIO needs WL12XX_PLATFORM_DATA
      compat-wireless: make patches apply again
      compat-wireless: generate CONFIG_COMPAT_KERNEL_38
      compat-wireless: make BRCMFMAC compile
      compat-wireless: correct rt2x00 config options
      compat-wireless: rename config symbols to CONFIG_WL12XX
      compat-wireless: fix CONFIG_BRCM80211 config option
      compat-wireless: remove double definition of CONFIG_SSB_DEBUG
      compat-wireless: make patches apply again
      compat-wireless: make patches apply again
      compat-wireless: make crap patches apply again
      compat-wireless: add new config options for ath5k
      compat-wireless: make patches apply again
      compat-wireless: make patch apply again
      compat-wireless: make patches apply again.
      compat-wireless: use pci_is_pcie()
      compat-wireless: add support for RTL8192CE
      compat-wireless: build led support conditionally
      compat-wireless: fix power managemnet backport
      compat-wireless: remove patches applied mainline
      compat-wireless: rtl8187 and rtl8180 moved
      compat-wireless: use generic suspend resume
      compat-wireless: make patches apply again.
      compat-wireless: use backported kfifo
      compat-wireless: make NEXT_TREE configurable.
      compat-wireless: update patches in enable-older-kernels
      compat-wireless: do not write git-clone
      compat-wireless: backport of alloc_ordered_workqueue into compat.git

Johannes Berg (1):
      compat-wirelesS: fix Intel driver-select

Luciano Coelho (1):
      compat-wireless: apply changes needed after wl1271->wl12xx renaming

Luis R. Rodriguez (57):
      compat-wireless: refresh patches
      compat-wireless: refresh crap patches
      compat-wireless: remove 28-pm-qos-params.patch
      compat-wireless: disable ar9170 when selecting ath
      compat-wireless: disable brcm80211 when selecting ath
      Revert "compat-wireless: apply changes needed after
wl1271->wl12xx renaming"
      compat-wireless: refresh patches
      compat-wireless: refresh crap patches
      Revert "Revert "compat-wireless: apply changes needed after
wl1271->wl12xx renaming""
      compat-wireless: refresh patches
      compat-wireless: refresh crap patches
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: fix crap packetlog patch
      compat-wireless: refresh crap patches
      compat-wireless: refresh patches
      compat-wireless: refresh crap patches
      compat-wireless: refresh patches
      compat-wireless: refresh crap patches
      compat-wireless: refresh patches
      compat-wireless: fix admin-update.sh for stable cherry picks
      compat-wireless: fix stable patch pull count
      compat-wireless: refresh patches for linux-next next-20101217
      compat-wireless: refresh crap patches for next-20101217
      compat-wireless: rt2x00 no uses a kfifo on the header
      compat-wireless: refresh patches
      compat-wireless: refresh crap patches
      compat-wireless: refresh patches for v2.6.38-rc2
      compat-wireless: refresh crap patches
      compat-wireless: First release for v2.6.37-rc3
      compat-wireless: fix stable pending tag mismatch output
      compat-wireless: skip directory if patches directory is empty
      compat-wireless: refresh patches
      compat-wireless: fix disable_bt
      compat-wireless: fix intel drivers on driver-select
      compat-wireless: refresh patches for 2.6.38-rc7
      compat-wireless: refresh crap patches for 2.6.38-rc7
      compat-wireless: remove old pending-stable ignore patch
      compat-wireless: remove present stable patch ath9k memory leak on PAPRD
      compat-wireless: empty commit to bump tag based on compat.git updates
      compat-wireless: refresh patches for v2.6.38 final
      compat-wireless: fix gen-stable-release.sh for git tree updates
      compat-wireless: add ath9k linux-cherry-picks for 2.6.38
      compat-wireless: fix
0008-ath9k-disable-beaconing-before-stopping-beacon-queue.patch
      compat-wireless: backport first series of patches for ath6kl
from linux-next
      compat-wireless: add second series of cherry picks for ath6kl
from linux-next
      compat-wireless: cherry pick ath6kl-Consolidating-hardware-configuration
      compat-wireless: backport two more ath6kl cherry picked patches
from linux-next
      compat-wireless: backport two more ath6kl cherry picked patches
      compat-wireless: backport last set of cherry picked patches for
ath6kl from linux-next
      compat-wireless: refresh linux-next-cherry-picks/ for 2.6.38
      compat-wireless: cherry pick
ath9k-Fix-a-PLL-hang-issue-observed-with-AR9485.patch
      compat-wireless: cherry pick for ath9k:
ath9k_hw-Add-a-function-to-read-sqsum_dvc.patch
      compat-wireless: add missing hunk for
0009-ath9k-improve-reliability-of-beacon-transmission-and.patch
      compat-wireless: fix hunk for
linux-next-cherry-picks/0009-ath9k-improve-reliability-of-beacon-transmission-and.patch
      compat-wireless: fix Makefile
      compat-wireless: add all pending-stable patches for 2.6.38

Senthil Balasubramanian (1):
      compat-wireless: Fix ath9k debug log issue.

Sven-Haegar Koch (1):
      compat-wireless: fix activesync devices

Timo Lindhorst (1):
      Add the header file for the new bluetooth management interface
to the     list of bluetooth include files.

Walter Goldens (2):
      compat-wireless: complete rtlwifi/RTL8192CE support
      compat-wireless: unify some driver-select colors
