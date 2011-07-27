From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [ANN] compat-wireless release for Linux 3.0
Date: Wed, 27 Jul 2011 15:58:24 -0700
Message-ID: <CAB=NE6UpMSRh4JCA676O3nwObX9ftVvRKu=HcWKVUFBwTLTCQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus flushed out Linux 3.0, the respective backport of that release
for the 802.11, Bluetooth and Networking subsystems is available now
[1]. Thanks for all the contributions, below are the compat.git and
compat-wireless.git contributions, for more details please refer to
the complete ChangeLog [2], and the stable compat-wireless page page
[3]. I've compile tested this against 2.6.38 and loaded iwlagn
successfully.

To discuss if we want to expand this framework to include other
subsystems we can talk about it in person at the 2011 Linux Plumbers
conference [4], should the BoF proposal get accepted. Farewell 2.6.x
days.

===============================================
ChangeLog for compat-wireless for linux-3.0
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

Release: linux-3.0


Updates from the compat.git project:
====================================

git shortlog linux-2.6.39.y..linux-3.0.y

Eliad Peller (1):
      compat: add an empty implementation for pm_wakeup_event()

Felix Fietkau (4):
      compat: add an empty definition for __rcu
      compat: backport rcu_dereference_protected
      compat: backport rcu_access_pointer
      compat: backport rtnl_dereference

Hauke Mehrtens (23):
      compat: backport netdev_refcnt_read.
      compat: add support for kernel 2.6.39
      compat: fix build for kernel < 2.6.29
      compat: semaphore.h mpoved from asm/ to linux/
      compat: integrate kfifo into compat.ko
      compat: add kstrtox
      compat: remove sdio_set_host_pm_flags
      compat: add time_to_tm
      compat: do not include kstrto* for kernel >= 2.6.38.4
      compat: fix TASK_INTERRUPTIBLE missing
      compat: backport vzalloc()
      compat: handle fail of vmalloc()
      compat: add missing include
      compat: backport kfree_rcu
      compat: backport ethtool_cmd_speed
      compat: add header linux/printk.h
      compat: backport rcu_dereference_raw
      compat: backport RCU_INIT_POINTER
      compat: remove wrong backport of kfree_rcu
      compat: add support for kernel 3.0
      compat: add device name in register_netdevice(dev)
      compat: rename CONFIG_COMPAT_KERNEL_
      compat: add KEY_WPS_BUTTON

Luis R. Rodriguez (2):
      compat: backport IRQ namespace cleanup
      compat: empty commit for 3.0 tag changes

Updates from the compat-wireless.git project:
=============================================

git shortlog linux-2.6.39.y..linux-3.0.y

Hauke Mehrtens (29):
      compat-wireless: add support for mwifiex
      compat-wireless: backport threaded irq for wl12xx_spi
      compat-wirless: deactivate PM support for libertas_spi for kernel < 2.6.29
      compat-wireless: fix compile warning for wl12xx
      compat-wireless: clean up the config file
      compat-wireless: Remove extra config option for kfifo.
      compat-wireless: make patches apply again
      compat-wireless: remove ar9170
      compat-wireless: make patches apply again
      compat-wireless: fix build of atheros Ethernet drivers.
      compat-wireless: update config options
      compat-wireless: use function for setting queue_mapping
      compat-wireless: fix compile problem with IRQF_ONESHOT
      compat-wireless: backport multicast filter in p54 for kernel < 2.6.35
      compat-wireless: make patches apply again
      compat-wireless: add RTL8192SE driver
      compat-wireless: enable RT33XX support.
      compat-wireless: make patches apply again
      compat-wireless: set CONFIG_COMPAT_STAGING=m
      compat-wireless: fix building of brcm80211
      Revert "compat-wireless: fix rfkill patches from applying"
      compat-wireless: adapt rename of dev to sdev in b43
      compat-wireless: revert usage of kfree_rcu
      compat-wireless: rename CONFIG_COMPAT_KERNEL_
      compat-wireless: add support for kernel 3.XX
      compat-wireless: activate CARL9170_WPC by default
      compat-wireless: activate CONFIG_RT2800{USB,PCI}_RT35XX by default.
      compat-wireless: sync atheros-debug.mk with config.mk
      compat-wireless: update enable-older-kernels patches

Johannes Berg (1):
      The sched_scan patches changed context for a patch.

Luis R. Rodriguez (19):
      compat-wireless: fix compilation warning for wl12xx
      compat-wireless: refresh patches for next-20110414
      compat-wireless: fix patches/09-threaded-irq.patch
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: fix patch dealing with lbs_pr_err() / pr_err()
      compat-wireless: fix rfkill patches from applying
      compat-wireless: fix applying of 09-threaded-irq.patch
      compat-wireless: refresh patches
      compat-wireless: patch updates for updates for 3.0.1-rc1 release
      compat-wireless: fixes for making 3.0 stable compat-wireless releases
      compat-wireless: refresh patches for 3.0-rc3
      compat-wireless: fix usb/Makefile patch for 3.0-rc4 release
      compat-wireless: refresh patches for 3.0-rc4
      compat-wireless: fix script for generating releases
      compat-wireless: refresh patches for 3.0 final release
      compat-wireless: dummy update for -2 release

[1] http://www.orbit-lab.org/kernel/compat-wireless-3.0-stable/v3.0/compat-wireless-3.0-2.tar.bz2
[2] http://www.orbit-lab.org/kernel/compat-wireless-3.0-stable/v3.0/ChangeLog-3.0-wireless
[3] http://wireless.kernel.org/en/users/Download/stable
[4] http://www.linuxplumbersconf.org/2011/ocw/proposals/771

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
