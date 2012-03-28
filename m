From: "Luis R. Rodriguez" <mcgrof-kCJ/WVjk54vrZ44/DZwexQ@public.gmane.org>
Subject: compat-wireless releases based on v3.3
Date: Tue, 27 Mar 2012 23:41:49 -0700
Message-ID: <CAB=NE6WgTMdDtU4_ZgYVr2XzSuiicT5o=q2RvV24jeQj0rZfFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lf_driver_backport-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linux v3.3 is out, so we make kernel backport releases based on this
release to allow you to compile subsystems / drivers from this kernel
on older kernels. One kernel backport release is based on v3.3 vanilla
[0], and another which cherry picks 14 patches from linux-next.git
[1]. The linux-next-cherry-picks patches are just one of the type of
extra categories of patches which the projects allows, for more
details refer to the additional patches page [2]. For details on the
changes that went into the kernel for the subsystem / drivers we
include in this release please refer to the ChangeLog [3]. Details to
compat and compat-wireless are provided below.

Worth mentioning is we now have a documentation page for the compat
module alone [4]. I've also dumped into a Google Fusion Table kernel
backport statistics [5] which we can use to keep metrics across
different releases. If anyone is interested in helping with these
stats or creating visualizations please let me know, for now anyone
can view the content. I'm still working on the columns, it seems there
a few bugs still with Fusion Table but the prospects of using it are
very nice. In particular I hope it can help organizations keep track
of deltas not upstream, help categorize clearly and keep metrics of
what is not even posted but needed (we call this crap), etc. There are
also slides available now [6] that will be used to for the Linux
Collaboration Summit talk on Automatically backporting the Linux
kernel [7]. Hope the new set of documentation helps understand this
process a little better.

The 14 cherry picked patches:

mcgrof@tux ~/devel/compat-wireless (git::linux-3.3.y)$ ls -1
linux-next-cherry-picks/
0001-mac80211-Fix-incorrect-num_sta_ps-decrement-in-__sta.patch
0002-mac80211-Fix-incorrect-num_sta_ps-decrement-in-ap_st.patch
0003-mac80211-Move-num_sta_ps-counter-decrement-after-syn.patch
0004-ath9k-Initialize-NF-values-properly.patch
0005-ath9k-Fix-programming-SYNTH4-for-AR9462.patch
0006-ath9k-Fix-descriptor-length-for-AR9462.patch
0007-mac80211-handle-non-bufferable-MMPDUs-correctly.patch
0008-Revert-ath9k_hw-Fix-false-tx-hung-detection-in-AR900.patch
0009-ath9k-do-not-call-ath9k_hw_txprocdesc-on-AR9003-outs.patch
0010-ath9k_hw-enable-interrupts-for-beacon-tx-completion-.patch
0011-ath9k-fix-drv_tx_last_beacon-on-AR9003-by-processing.patch
0012-ath9k_hw-use-cold-instead-of-warm-reset-on-AR9280.patch
0013-mac80211-add-an-rx-flag-for-ignoring-a-packet-s-sign.patch
0014-ath9k-fix-signal-strength-reporting-issues.patch


===============================================
ChangeLog for compat-wireless for linux-3.3
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
stable release. A branch called linux-3.x.y exists for each
stable release. Below we provide the ChangeLog of changes from
the previous branched release to the new branched release.

Release: linux-3.3

Updates from the compat.git project:
====================================

git shortlog linux-3.2.y..linux-3.3.y

Felix Fietkau (3):
      compat: fix misplaced #ifdef for the workqueue backport
      compat: backport atomic64 support
      compat: fix security_sk_clone dummy backport compile

Hauke Mehrtens (6):
      compat: add support for kernel 3.2
      compat: backport kfree_rcu()
      compat: backport netdev_features_t
      compat: add config var for CORDIC and CRC8
      compat: add module_usb_driver and module_platform_driver
      compat: add __cancel_delayed_work()

John W. Linville (7):
      compat: use separate CONFIG_COMPAT_KFIFO option for building kfifo.o
      compat: add CONFIG_COMPAT_FIRMWARE_DATA_RW_NEEDS_FILP
      compat: check CONFIG_COMPAT_FIRMWARE_CLASS in compat-2.6.33.h
      compat: support RHEL6 as a build target
      compat: avoid warning in compat_system_workqueue_create
      compat: implement dummy security_sk_clone
      compat: use kconfig.h in compat-2.6.h for 3.1 and later kernels

Luis R. Rodriguez (4):
      compat: fix building for 3.0 kernels
      compat: export compat kernel versions info
      compat: add .gitignore
      compat: add compat kernel checker and downloader

Nikolay Martynov (1):
      Add dma_zalloc_coherent to fix build with kernels older than 3.2

Updates from the compat-wireless.git project:
=============================================

git shortlog linux-3.2.y..linux-3.3.y

Dominique Martinet (1):
      compat-wireless: build: Throw error if space in path

Eliad Peller (1):
      compat-wireless: fix patches/08-rename-config-options.patch

Hauke Mehrtens (17):
      compat-wireless: add support for kernel 3.2
      compat-wireless: remove kfree_rcu() patch
      compat-wireless: make patches apply again
      compat-wireless: make patches apply again
      compat-wireless: escape &
      compat-wireless: add config var for CORDIC and CRC8
      compat-wireless: remove some modules from Makefile
      compat-wireless: fix driver-select for intel
      compat-wireless: add some missing config options
      compat-wireless: fix brcm80211 driver-select
      compat-wireless deactivate mac80211 tracing for old kernels
      compat-wireless: compile fix for commit patches/09-threaded-irq.patch
      compat-wireless: remove platform_device_id for kernel < 2.6.30
      compat-wireless: CONFIG_BT_L2CAP and CONFIG_BT_SCO removed
      compat-wireless: make patches apply again
      compat-wireless: use other workqueue
      compat-wireless: no trans_start on netdev_queue

Johannes Berg (1):
      compat-wireless: disable SKB TX status stamping in mac80211

John W. Linville (9):
      compat-wireless: add CONFIG_COMPAT_KFIFO setting to config.mk
      compat-wireless: remove leading whitespace from
CONFIG_COMPAT_FIRMWARE_CLASS
      compat-wireless: add CONFIG_COMPAT_BT_SOCK_CREATE_NEEDS_KERN
      compat-wireless: support RHEL6 as a build target
      compat-wireless: change CONFIG_IWLAGN -> CONFIG_IWLWIFI
      compat-wireless: fix patches/11-dev-pm-ops.patch
      compat-wireless: fix patches/38-led-max-brightness.patch
      compat-wireless: fix patches/39-remove_blink_set.patch
      Enable CONFIG_RT2800{PCI,USB}_RT53XX

Luciano Coelho (1):
      compat-wireless: check if modprobe exists before using it

Luis R. Rodriguez (22):
      compat-wireless: fix patches/08-rename-config-options.patch
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: fix patches/09-threaded-irq.patch
      compat-wireless: refresh patches
      compat-wireless: copy driver files only if present
      compat-wireless: clarify patches/47-no_trans_start_on_netdev_queue.patch
      compat-wireless: clarify patches/46-use_other_workqueue.patch
      compat-wireless: refresh patches
      compat-wireless: refresh patches for next-20120109
      compat-wirless: refresh patches
      compat-wireless: refresh patches for 3.3-rc1
      compat-wireless: use linux-stable instead of linux-2.6-allstable
      compat-wireless: fix patches/16-bluetooth.patch
      compat-wireless: refresh patches
      compat-wireless: add driver-select option ath9k_ap
      compat-wireless: fix allowing jobserver
      compat-wireless: add linux-next-cherry-picks for 3.3 recommended by nbd
      compat-wireless: refresh linux-next-cherry-picks patches
      compat-wireless: remove ath9k packet log crap
      compat-wireless: remove stale pending-stable ignore patch
      compat-wireless: refresh patches for v3.0 release

[0] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-1.tar.bz2
[1] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-1-n.tar.bz2
[2] http://wireless.kernel.org/en/users/Download/stable/#Additional_patches_to_stable_releases
[3] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/ChangeLog-3.3-wireless
[4] http://mcgrof.github.com/compat/
[5] https://www.google.com/fusiontables/DataSource?docid=1wXnm0VFUHBpaMmxwjaZZD58B4o8K1iPFCCOx50Q
[6] https://docs.google.com/presentation/d/1axVNEGwKZjnzG1ocdd289WMqPxzJ3qfMv70ghGcnUKc/edit
[7] https://events.linuxfoundation.org/events/collaboration-summit/rodriguez-backporting

  Luis
