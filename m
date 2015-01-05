From: ael <lawrence_a_e@ntlworld.com>
Subject: r8169 crash also in 3.16.7
Date: Mon, 5 Jan 2015 11:20:44 +0000
Message-ID: <20150105112044.GA5659@shelf.conquest>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgout0502.bt.lon5.cpcloud.co.uk ([65.20.0.223]:58339 "EHLO
	rgout0502.bt.lon5.cpcloud.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753375AbbAEL1T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 06:27:19 -0500
Received: from shelf.conquest (82.16.132.17) by rgout05.bt.lon5.cpcloud.co.uk (8.6.122.06) (authenticated as lawrenceae@btinternet.com)
        id 5493F177019823CE for netdev@vger.kernel.org; Mon, 5 Jan 2015 11:20:44 +0000
Received: from ael by shelf.conquest with local (Exim 4.84)
	(envelope-from <ael@shelf.conquest>)
	id 1Y85iG-0001Tp-2m
	for netdev@vger.kernel.org; Mon, 05 Jan 2015 11:20:44 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jan  4 22:07:59 shelf kernel: [10572.511389] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Jan  4 22:09:16 shelf kernel: [10650.233166] ------------[ cut here ]------------
Jan  4 22:09:16 shelf kernel: [10650.233180] WARNING: CPU: 0 PID: 0 at /build/linux-CMiYW9/linux-3.16.7-ckt2/net/sched/sch_generic.c:264 dev_watchdog+0x236/0x240()
Jan  4 22:09:16 shelf kernel: [10650.233183] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Jan  4 22:09:16 shelf kernel: [10650.233184] Modules linked in: nls_utf8 isofs binfmt_misc snd_hrtimer snd_seq snd_seq_device bnep uvcvideo videobuf2_vmalloc ecb videobuf2_memops videobuf2_core v4l2_common btusb videodev media bluetooth 6lowpan_iphc nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache snd_hda_codec_hdmi sunrpc joydev arc4 snd_hda_codec_realtek snd_hda_codec_generic x86_pkg_temp_thermal intel_powerclamp intel_rapl coretemp rtsx_pci_sdmmc rtsx_pci_ms kvm_intel mmc_core memstick kvm iTCO_wdt iwlmvm iTCO_vendor_support crc32_pclmul crc32c_intel mac80211 ghash_clmulni_intel iwlwifi aesni_intel i915 cfg80211 snd_hda_intel aes_x86_64 snd_hda_controller lrw xhci_hcd snd_hda_codec ehci_pci gf128mul snd_hwdep glue_helper ehci_hcd ablk_helper r8169 snd_pcm cryptd drm_kms_helper sn
 d_timer usbcore rfkill mii mei_me snd drm sg rtsx_pci usb_common soundcore evdev mei sr_mod i2c_algo_bit psmouse lpc_ich cdrom mfd_core i2c_i801 serio_raw pcspkr shpchp i2c_core wmi tpm_infineon tpm_tis tpm video battery button ac processor fuse parport_pc ppdev lp parport autofs4 ext4 crc16 mbcache jbd2 sd_mod crc_t10dif crct10dif_generic ahci libahci crct10dif_pclmul crct10dif_common libata scsi_mod thermal thermal_sys
Jan  4 22:09:16 shelf kernel: [10650.233261] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.16.0-4-amd64 #1 Debian 3.16.7-ckt2-1
Jan  4 22:09:16 shelf kernel: [10650.233263] Hardware name: Notebook                         W54_55SU1,SUW/W54_55SU1,SUW, BIOS 4.6.5 05/29/2014
Jan  4 22:09:16 shelf kernel: [10650.233265]  0000000000000009 ffffffff81507263 ffff88041fa03e28 ffffffff81065847
Jan  4 22:09:16 shelf kernel: [10650.233270]  0000000000000000 ffff88041fa03e78 0000000000000001 0000000000000000
Jan  4 22:09:16 shelf kernel: [10650.233273]  ffff88040e138000 ffffffff810658ac ffffffff81776df8 ffff880400000030
Jan  4 22:09:16 shelf kernel: [10650.233278] Call Trace:
Jan  4 22:09:16 shelf kernel: [10650.233280]  <IRQ>  [<ffffffff81507263>] ? dump_stack+0x41/0x51
Jan  4 22:09:16 shelf kernel: [10650.233290]  [<ffffffff81065847>] ? warn_slowpath_common+0x77/0x90
Jan  4 22:09:16 shelf kernel: [10650.233293]  [<ffffffff810658ac>] ? warn_slowpath_fmt+0x4c/0x50
Jan  4 22:09:16 shelf kernel: [10650.233298]  [<ffffffff8143aa46>] ? dev_watchdog+0x236/0x240
Jan  4 22:09:16 shelf kernel: [10650.233304]  [<ffffffff8143a810>] ? dev_graft_qdisc+0x70/0x70
Jan  4 22:09:16 shelf kernel: [10650.233309]  [<ffffffff81070b01>] ? call_timer_fn+0x31/0x100
Jan  4 22:09:16 shelf kernel: [10650.233314]  [<ffffffff8143a810>] ? dev_graft_qdisc+0x70/0x70
Jan  4 22:09:16 shelf kernel: [10650.233318]  [<ffffffff81072139>] ? run_timer_softirq+0x209/0x2f0
Jan  4 22:09:16 shelf kernel: [10650.233322]  [<ffffffff8106a6e1>] ? __do_softirq+0xf1/0x290
Jan  4 22:09:16 shelf kernel: [10650.233326]  [<ffffffff8106aab5>] ? irq_exit+0x95/0xa0
Jan  4 22:09:16 shelf kernel: [10650.233332]  [<ffffffff815101d5>] ? smp_apic_timer_interrupt+0x45/0x60
Jan  4 22:09:16 shelf kernel: [10650.233336]  [<ffffffff8150e2bd>] ? apic_timer_interrupt+0x6d/0x80
Jan  4 22:09:16 shelf kernel: [10650.233338]  <EOI>  [<ffffffff81088cad>] ? __hrtimer_start_range_ns+0x1cd/0x390
Jan  4 22:09:16 shelf kernel: [10650.233347]  [<ffffffff813da452>] ? cpuidle_enter_state+0x52/0xc0
Jan  4 22:09:16 shelf kernel: [10650.233352]  [<ffffffff813da448>] ? cpuidle_enter_state+0x48/0xc0
Jan  4 22:09:16 shelf kernel: [10650.233356]  [<ffffffff810a5e78>] ? cpu_startup_entry+0x2f8/0x400
Jan  4 22:09:16 shelf kernel: [10650.233362]  [<ffffffff81902071>] ? start_kernel+0x492/0x49d
Jan  4 22:09:16 shelf kernel: [10650.233366]  [<ffffffff81901a04>] ? set_init_arg+0x4e/0x4e
Jan  4 22:09:16 shelf kernel: [10650.233370]  [<ffffffff81901120>] ? early_idt_handlers+0x120/0x120
Jan  4 22:09:16 shelf kernel: [10650.233374]  [<ffffffff8190171f>] ? x86_64_start_kernel+0x14d/0x15c
Jan  4 22:09:16 shelf kernel: [10650.233376] ---[ end trace baa62b1e2bf27ca5 ]---
Jan  4 22:09:16 shelf kernel: [10650.267368] r8169 0000:03:00.1 eth0: link up
Jan  4 22:09:59 shelf kernel: [10692.651854] r8169 0000:03:00.1 eth0: link down

ael
