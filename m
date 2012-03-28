From: Richard Farina <sidhayn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: compat-wireless releases based on v3.3
Date: Wed, 28 Mar 2012 03:19:27 -0400
Message-ID: <4F72BB7F.8080704@gmail.com>
References: <CAB=NE6WgTMdDtU4_ZgYVr2XzSuiicT5o=q2RvV24jeQj0rZfFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lf_driver_backport-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-kCJ/WVjk54vrZ44/DZwexQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6WgTMdDtU4_ZgYVr2XzSuiicT5o=q2RvV24jeQj0rZfFw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/28/12 02:41, Luis R. Rodriguez wrote:
> Linux v3.3 is out, so we make kernel backport releases based on this
> release to allow you to compile subsystems / drivers from this kernel
> on older kernels. One kernel backport release is based on v3.3 vanilla
> [0], and another which cherry picks 14 patches from linux-next.git
> [1]. The linux-next-cherry-picks patches are just one of the type of
> extra categories of patches which the projects allows, for more
> details refer to the additional patches page [2]. For details on the
> changes that went into the kernel for the subsystem / drivers we
> include in this release please refer to the ChangeLog [3]. Details to
> compat and compat-wireless are provided below.
>
> Worth mentioning is we now have a documentation page for the compat
> module alone [4]. I've also dumped into a Google Fusion Table kernel
> backport statistics [5] which we can use to keep metrics across
> different releases. If anyone is interested in helping with these
> stats or creating visualizations please let me know, for now anyone
> can view the content. I'm still working on the columns, it seems there
> a few bugs still with Fusion Table but the prospects of using it are
> very nice. In particular I hope it can help organizations keep track
> of deltas not upstream, help categorize clearly and keep metrics of
> what is not even posted but needed (we call this crap), etc. There are
> also slides available now [6] that will be used to for the Linux
> Collaboration Summit talk on Automatically backporting the Linux
> kernel [7]. Hope the new set of documentation helps understand this
> process a little better.
-1 compiles perfectly for me
> The 14 cherry picked patches:
>
> mcgrof@tux ~/devel/compat-wireless (git::linux-3.3.y)$ ls -1
> linux-next-cherry-picks/
> 0001-mac80211-Fix-incorrect-num_sta_ps-decrement-in-__sta.patch
> 0002-mac80211-Fix-incorrect-num_sta_ps-decrement-in-ap_st.patch
> 0003-mac80211-Move-num_sta_ps-counter-decrement-after-syn.patch
> 0004-ath9k-Initialize-NF-values-properly.patch
> 0005-ath9k-Fix-programming-SYNTH4-for-AR9462.patch
> 0006-ath9k-Fix-descriptor-length-for-AR9462.patch
> 0007-mac80211-handle-non-bufferable-MMPDUs-correctly.patch
> 0008-Revert-ath9k_hw-Fix-false-tx-hung-detection-in-AR900.patch
> 0009-ath9k-do-not-call-ath9k_hw_txprocdesc-on-AR9003-outs.patch
> 0010-ath9k_hw-enable-interrupts-for-beacon-tx-completion-.patch
> 0011-ath9k-fix-drv_tx_last_beacon-on-AR9003-by-processing.patch
> 0012-ath9k_hw-use-cold-instead-of-warm-reset-on-AR9280.patch
> 0013-mac80211-add-an-rx-flag-for-ignoring-a-packet-s-sign.patch
> 0014-ath9k-fix-signal-strength-reporting-issues.patch
>
Something goes wrong with 1-n:

make -j1 KLIB_BUILD=/lib/modules/3.2.2-pentoo/build
./scripts/gen-compat-autoconf.sh config.mk > include/linux/compat_autoconf.h
make -C /lib/modules/3.2.2-pentoo/build
M=/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n
modules
make[1]: Entering directory `/usr/src/linux-3.2.2-pentoo'
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/compat/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/compat/main.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/compat/compat.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/scan.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/core.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/sprom.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/driver_chipcommon.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/driver_chipcommon_pmu.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/driver_pci.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/host_pci.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bcma/bcma.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_vhci.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btmrvl_main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btmrvl_debugfs.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_ldisc.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_h4.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_bcsp.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_ll.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_ath.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/hci_uart.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/bcm203x.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/bpa10x.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/bfusb.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/dtl1_cs.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/bt3c_cs.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/bluecard_cs.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btuart_cs.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btusb.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btsdio.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/ath3k.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btmrvl.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btmrvl_sdio.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/bluetooth/btwilink.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/misc/eeprom/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/misc/eeprom/eeprom_93cx6.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/built-in.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1c/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1c/atl1c_main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1c/atl1c_hw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1c/atl1c.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1e/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1e/atl1e_main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1e/atl1e_hw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1e/atl1e_param.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atl1e/atl1e.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atlx/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atlx/atl1.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/atheros/atlx/atl2.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/broadcom/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/broadcom/b44.o
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/ethernet/broadcom/b44.c:13:0:
warning: "pr_fmt" redefined
include/linux/printk.h:152:0: note: this is the location of the previous
definition
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/usb/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/usb/cdc_ether.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/usb/rndis_host.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/usb/usbnet.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/regd.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/hw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/key.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/caps.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/initvals.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/eeprom.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/gpio.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/desc.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/dma.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/qcu.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/pcu.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/phy.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/reset.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/attach.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/base.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/led.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/rfkill.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/ani.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/sysfs.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/mac80211-ops.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/pci.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath5k/ath5k.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/debug.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/hif.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/htc.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/bmi.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/cfg80211.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/init.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/txrx.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/wmi.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/sdio.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath6kl/ath6kl.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/beacon.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/gpio.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/init.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/recv.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/xmit.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/mci.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/rc.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/pci.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ahb.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/common.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/htc_hst.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/hif_usb.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/wmi.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/htc_drv_txrx.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/htc_drv_main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/htc_drv_beacon.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/htc_drv_init.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/htc_drv_gpio.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9002_hw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_hw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/hw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_phy.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9002_phy.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar5008_phy.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9002_calib.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_calib.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_rtt.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/calib.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/eeprom.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/eeprom_def.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/eeprom_4k.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/eeprom_9287.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ani.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/btcoex.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/mac.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9002_mac.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_mac.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_eeprom.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_paprd.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ar9003_mci.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ath9k.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ath9k_hw.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ath9k_common.o
  LD [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/ath9k/ath9k_htc.o
  LD     
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/built-in.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/main.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/usb.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/cmd.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/mac.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/phy.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/led.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/fw.o
  CC [M] 
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.o
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:
In function 'carl9170_tx_ps_drop':
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:1248:26:
error: 'IEEE80211_TX_CTL_POLL_RESPONSE' undeclared (first use in this
function)
/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:1248:26:
note: each undeclared identifier is reported only once for each function
it appears in
make[5]: ***
[/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.o]
Error 1
make[4]: ***
[/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170]
Error 2
make[3]: ***
[/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath]
Error 2
make[2]: ***
[/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless]
Error 2
make[1]: ***
[_module_/var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n]
Error 2
make[1]: Leaving directory `/usr/src/linux-3.2.2-pentoo'
make: *** [modules] Error 2

thanks!

-Rick
> ===============================================
> ChangeLog for compat-wireless for linux-3.3
> ===============================================
>
> This is the ChangeLog for the Linux kernel project compat-wireless.
> It provides a backport of a few Linux kernel subsystems down to
> older kernels:
>
>   * 802.11
>   * Bluetooth
>   * Ethernet
>
> For more details refer to the home page:
>
> http://wireless.kernel.org/en/users/Download/stable/
>
> The compat-wireless project consists of code from three projects:
>
>   * The Linux kernel: linux-2.6-allstable.git
>   * Compat-wirelesS: compat-wireless.git
>   * Compat: compat.git
>
> The compat-wireless stable releases incorporates code from from
> each of these git trees for the respective upstream Linux kernel
> stable release. A branch called linux-3.x.y exists for each
> stable release. Below we provide the ChangeLog of changes from
> the previous branched release to the new branched release.
>
> Release: linux-3.3
>
> Updates from the compat.git project:
> ====================================
>
> git shortlog linux-3.2.y..linux-3.3.y
>
> Felix Fietkau (3):
>       compat: fix misplaced #ifdef for the workqueue backport
>       compat: backport atomic64 support
>       compat: fix security_sk_clone dummy backport compile
>
> Hauke Mehrtens (6):
>       compat: add support for kernel 3.2
>       compat: backport kfree_rcu()
>       compat: backport netdev_features_t
>       compat: add config var for CORDIC and CRC8
>       compat: add module_usb_driver and module_platform_driver
>       compat: add __cancel_delayed_work()
>
> John W. Linville (7):
>       compat: use separate CONFIG_COMPAT_KFIFO option for building kfifo.o
>       compat: add CONFIG_COMPAT_FIRMWARE_DATA_RW_NEEDS_FILP
>       compat: check CONFIG_COMPAT_FIRMWARE_CLASS in compat-2.6.33.h
>       compat: support RHEL6 as a build target
>       compat: avoid warning in compat_system_workqueue_create
>       compat: implement dummy security_sk_clone
>       compat: use kconfig.h in compat-2.6.h for 3.1 and later kernels
>
> Luis R. Rodriguez (4):
>       compat: fix building for 3.0 kernels
>       compat: export compat kernel versions info
>       compat: add .gitignore
>       compat: add compat kernel checker and downloader
>
> Nikolay Martynov (1):
>       Add dma_zalloc_coherent to fix build with kernels older than 3.2
>
> Updates from the compat-wireless.git project:
> =============================================
>
> git shortlog linux-3.2.y..linux-3.3.y
>
> Dominique Martinet (1):
>       compat-wireless: build: Throw error if space in path
>
> Eliad Peller (1):
>       compat-wireless: fix patches/08-rename-config-options.patch
>
> Hauke Mehrtens (17):
>       compat-wireless: add support for kernel 3.2
>       compat-wireless: remove kfree_rcu() patch
>       compat-wireless: make patches apply again
>       compat-wireless: make patches apply again
>       compat-wireless: escape &
>       compat-wireless: add config var for CORDIC and CRC8
>       compat-wireless: remove some modules from Makefile
>       compat-wireless: fix driver-select for intel
>       compat-wireless: add some missing config options
>       compat-wireless: fix brcm80211 driver-select
>       compat-wireless deactivate mac80211 tracing for old kernels
>       compat-wireless: compile fix for commit patches/09-threaded-irq.patch
>       compat-wireless: remove platform_device_id for kernel < 2.6.30
>       compat-wireless: CONFIG_BT_L2CAP and CONFIG_BT_SCO removed
>       compat-wireless: make patches apply again
>       compat-wireless: use other workqueue
>       compat-wireless: no trans_start on netdev_queue
>
> Johannes Berg (1):
>       compat-wireless: disable SKB TX status stamping in mac80211
>
> John W. Linville (9):
>       compat-wireless: add CONFIG_COMPAT_KFIFO setting to config.mk
>       compat-wireless: remove leading whitespace from
> CONFIG_COMPAT_FIRMWARE_CLASS
>       compat-wireless: add CONFIG_COMPAT_BT_SOCK_CREATE_NEEDS_KERN
>       compat-wireless: support RHEL6 as a build target
>       compat-wireless: change CONFIG_IWLAGN -> CONFIG_IWLWIFI
>       compat-wireless: fix patches/11-dev-pm-ops.patch
>       compat-wireless: fix patches/38-led-max-brightness.patch
>       compat-wireless: fix patches/39-remove_blink_set.patch
>       Enable CONFIG_RT2800{PCI,USB}_RT53XX
>
> Luciano Coelho (1):
>       compat-wireless: check if modprobe exists before using it
>
> Luis R. Rodriguez (22):
>       compat-wireless: fix patches/08-rename-config-options.patch
>       compat-wireless: refresh patches
>       compat-wireless: refresh patches
>       compat-wireless: fix patches/09-threaded-irq.patch
>       compat-wireless: refresh patches
>       compat-wireless: copy driver files only if present
>       compat-wireless: clarify patches/47-no_trans_start_on_netdev_queue.patch
>       compat-wireless: clarify patches/46-use_other_workqueue.patch
>       compat-wireless: refresh patches
>       compat-wireless: refresh patches for next-20120109
>       compat-wirless: refresh patches
>       compat-wireless: refresh patches for 3.3-rc1
>       compat-wireless: use linux-stable instead of linux-2.6-allstable
>       compat-wireless: fix patches/16-bluetooth.patch
>       compat-wireless: refresh patches
>       compat-wireless: add driver-select option ath9k_ap
>       compat-wireless: fix allowing jobserver
>       compat-wireless: add linux-next-cherry-picks for 3.3 recommended by nbd
>       compat-wireless: refresh linux-next-cherry-picks patches
>       compat-wireless: remove ath9k packet log crap
>       compat-wireless: remove stale pending-stable ignore patch
>       compat-wireless: refresh patches for v3.0 release
>
> [0] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-1.tar.bz2
> [1] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-1-n.tar.bz2
> [2] http://wireless.kernel.org/en/users/Download/stable/#Additional_patches_to_stable_releases
> [3] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/ChangeLog-3.3-wireless
> [4] http://mcgrof.github.com/compat/
> [5] https://www.google.com/fusiontables/DataSource?docid=1wXnm0VFUHBpaMmxwjaZZD58B4o8K1iPFCCOx50Q
> [6] https://docs.google.com/presentation/d/1axVNEGwKZjnzG1ocdd289WMqPxzJ3qfMv70ghGcnUKc/edit
> [7] https://events.linuxfoundation.org/events/collaboration-summit/rodriguez-backporting
>
>   Luis
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
