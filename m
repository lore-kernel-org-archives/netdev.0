From: ael <law_ence.dev@ntlworld.com>
Subject: Bug#763325: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 13 Oct 2014 21:20:23 +0100
Message-ID: <20141013202023.GA4601@shelf.conquest>
Reply-To: ael <law_ence.dev@ntlworld.com>, 763325@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 763325@bugs.debian.org
To: netdev@vger.kernel.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.763325.B763325.141323163615229@bugs.debian.org>
Content-Disposition: inline
List-URL: <http://lists.debian.org/debian-bugs-dist/>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

It was suggested that I post this bug here.
>From /var/log/messages:
=======================================================================

Oct  6 14:16:29 shelf kernel: [  961.633769] ------------[ cut here ]------------
Oct  6 14:16:29 shelf kernel: [  961.633790] WARNING: CPU: 0 PID: 0 at /build/linux-P15SNz/linux-3.16.3/net/sched/sch_generic.c:264
dev_watchdog+0x236/0x240()
Oct  6 14:16:29 shelf kernel: [  961.633792] NETDEV WATCHDOG: eth0
(r8169): transmit queue 0 timed out
Oct  6 14:16:29 shelf kernel: [  961.633794] Modules linked in:
sha256_ssse3 sha256_generic dm_crypt dm_mod usb_storage uinput cpuid
snd_hrtimer binfmt_misc snd_seq snd_seq_device bnep joydev nfsd
auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc
snd_hda_codec_realtek iTCO_wdt snd_hda_codec_hdmi snd_hda_codec_generic
iTCO_vendor_support ecb uvcvideo videobuf2_vmalloc btusb
videobuf2_memops videobuf2_core v4l2_common bluetooth videodev media
6lowpan_iphc arc4 rtsx_pci_sdmmc rtsx_pci_ms iwlmvm memstick mmc_core
mac80211 iwlwifi cfg80211 r8169 rtsx_pci mii rfkill x86_pkg_temp_thermal
intel_powerclamp intel_rapl coretemp kvm_intel kvm crc32_pclmul
crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul
glue_helper ablk_helper cryptd lpc_ich evdev psmouse snd_hda_intel
serio_raw sr_mod snd_hda_controller pcspkr sg snd_hda_codec cdrom
mfd_core tpm_infineon i915 snd_hwdep i2c_i801 wmi shpchp snd_pcm
ehci_pci snd_timer tpm_tis drm_kms_helper ehci_hcd xhci_hcd snd drm
soundcore tpm i2c_algo_bit mei_me usbcore i2c_core mei video usb_common
ac battery processor button fuse parport_pc ppdev lp parport autofs4
ext4 crc16 mbcache jbd2 sd_mod crc_t10dif crct10dif_generic ahci libahci
crct10dif_pclmul crct10dif_common libata scsi_mod thermal thermal_sys
Oct  6 14:16:29 shelf kernel: [  961.633898] CPU: 0 PID: 0 Comm:
swapper/0 Not tainted 3.16-2-amd64 #1 Debian 3.16.3-2
Oct  6 14:16:29 shelf kernel: [  961.633899] Hardware name:
Notebook                         W54_55SU1,SUW/W54_55SU1,SUW, BIOS 4.6.5
05/29/2014
Oct  6 14:16:29 shelf kernel: [  961.633901]  0000000000000009 ffffffff81506188 ffff88041fa03e28 ffffffff81065707
Oct  6 14:16:29 shelf kernel: [  961.633903]  0000000000000000
ffff88041fa03e78 0000000000000001 0000000000000000
Oct  6 14:16:29 shelf kernel: [  961.633907]  ffff88040a0ec000
ffffffff8106576c ffffffff81775ca0 0000000000000030
Oct  6 14:16:29 shelf kernel: [  961.633912] Call Trace:
Oct  6 14:16:29 shelf kernel: [  961.633914]  <IRQ>
[<ffffffff81506188>] ? dump_stack+0x41/0x51
Oct  6 14:16:29 shelf kernel: [  961.633922]  [<ffffffff81065707>] ?
warn_slowpath_common+0x77/0x90
Oct  6 14:16:29 shelf kernel: [  961.633926]  [<ffffffff8106576c>] ?
warn_slowpath_fmt+0x4c/0x50
Oct  6 14:16:29 shelf kernel: [  961.633930]  [<ffffffff81439af6>] ?
dev_watchdog+0x236/0x240
Oct  6 14:16:29 shelf kernel: [  961.633936]  [<ffffffff814398c0>] ?
dev_graft_qdisc+0x70/0x70
Oct  6 14:16:29 shelf kernel: [  961.633941]  [<ffffffff810709c1>] ?
call_timer_fn+0x31/0x100
Oct  6 14:16:29 shelf kernel: [  961.633945]  [<ffffffff814398c0>] ?
dev_graft_qdisc+0x70/0x70
Oct  6 14:16:29 shelf kernel: [  961.633948]  [<ffffffff81071ff9>] ?
run_timer_softirq+0x209/0x2f0
Oct  6 14:16:29 shelf kernel: [  961.633953]  [<ffffffff8106a5a1>] ?
__do_softirq+0xf1/0x290
Oct  6 14:16:29 shelf kernel: [  961.633956]  [<ffffffff8106a975>] ?
irq_exit+0x95/0xa0
Oct  6 14:16:29 shelf kernel: [  961.633961]  [<ffffffff8150f155>] ?
smp_apic_timer_interrupt+0x45/0x60
Oct  6 14:16:29 shelf kernel: [  961.633965]  [<ffffffff8150d25d>] ?
apic_timer_interrupt+0x6d/0x80
Oct  6 14:16:29 shelf kernel: [  961.633968]  <EOI>
[<ffffffff81088b5d>] ? __hrtimer_start_range_ns+0x1cd/0x390
Oct  6 14:16:29 shelf kernel: [  961.633976]  [<ffffffff813d96e2>] ?
cpuidle_enter_state+0x52/0xc0
Oct  6 14:16:29 shelf kernel: [  961.633980]  [<ffffffff813d96d8>] ?
cpuidle_enter_state+0x48/0xc0
Oct  6 14:16:29 shelf kernel: [  961.633984]  [<ffffffff810a5d28>] ?
cpu_startup_entry+0x2f8/0x400
Oct  6 14:16:29 shelf kernel: [  961.633989]  [<ffffffff8190305a>] ?
start_kernel+0x47b/0x486
Oct  6 14:16:29 shelf kernel: [  961.633993]  [<ffffffff81902a04>] ?
set_init_arg+0x4e/0x4e
Oct  6 14:16:29 shelf kernel: [  961.633997]  [<ffffffff81902120>] ?
early_idt_handlers+0x120/0x120
Oct  6 14:16:29 shelf kernel: [  961.634000]  [<ffffffff8190271f>] ?
x86_64_start_kernel+0x14d/0x15c
Oct  6 14:16:29 shelf kernel: [  961.634004] ---[ end trace
065e688ac03d9c53 ]---
Oct  6 14:16:29 shelf kernel: [  961.657322] r8169 0000:03:00.1 eth0:
link up
===================================================================

I believe I was changing from ethernet to wireless frequently while
doing some testing just before this particular instance. However this
bug is typicaly trigggered several times when just using eth0 and has
been happening for the last week.

For completeness, here are extracts from the log before the instance
above (when I was probably explicitly taking eth0 up and down, so it
possibly has irrelevant noise from those activities):

Oct  6 13:59:06 shelf kernel: [    1.466463] r8169 0000:03:00.1 eth0:
RTL8411 at 0xffffc900018c4000, 80:fa:5b:04:ca:96, XID 1c800880 IRQ 44
Oct  6 13:59:06 shelf kernel: [    1.466470] r8169 0000:03:00.1 eth0:
jumbo features [frames: 9200 bytes, tx checksumming: ko]
--[snip]--
Oct  6 13:59:06 shelf kernel: [    1.556245] r8169 0000:03:00.1:
firmware: direct-loading firmware rtl_nic/rtl8411-2.fw
Oct  6 13:59:06 shelf kernel: [    1.571948] r8169 0000:03:00.1 eth0:
link down
--[snip]--
Oct  6 13:59:09 shelf kernel: [    5.463398] r8169 0000:03:00.1 eth0:
link up
--[snip]--
Oct  6 14:09:17 shelf kernel: [  545.893079] r8169 0000:03:00.1 eth0:
link down
--[snip]--
Oct  6 14:09:17 shelf kernel: [  547.647632] r8169 0000:03:00.1: no
hotplug settings from platform
Oct  6 14:09:17 shelf kernel: [  547.648327] done.
Oct  6 14:09:17 shelf kernel: [  547.660691] Bluetooth: hci0: read Intel
version: 370710018002030d37
Oct  6 14:09:17 shelf kernel: [  547.660693] Bluetooth: hci0: Intel
device is already patched. patch num: 37
Oct  6 14:09:17 shelf kernel: [  547.805664] [drm] Enabling RC6 states:
RC6 on, RC6p off, RC6pp off
Oct  6 14:09:23 shelf kernel: [  553.115079] r8169 0000:03:00.1 eth0:
link up
Oct  6 14:09:24 shelf kernel: [  554.134710] r8169 0000:03:00.1 eth0:
link down
Oct  6 14:09:27 shelf kernel: [  557.556657] r8169 0000:03:00.1 eth0:
link up
Oct  6 14:09:28 shelf kernel: [  558.578349] r8169 0000:03:00.1 eth0:
link down
Oct  6 14:09:32 shelf kernel: [  562.018553] r8169 0000:03:00.1 eth0:
link up
Oct  6 14:09:33 shelf kernel: [  563.040819] r8169 0000:03:00.1 eth0:
link down
Oct  6 14:09:36 shelf kernel: [  566.548111] r8169 0000:03:00.1 eth0:
link up
Oct  6 14:09:37 shelf kernel: [  567.568219] r8169 0000:03:00.1 eth0:
link down
Oct  6 14:09:41 shelf kernel: [  571.786079] r8169 0000:03:00.1 eth0:
link up
Oct  6 14:09:42 shelf kernel: [  572.808291] r8169 0000:03:00.1 eth0:
link down
Oct  6 14:09:45 shelf kernel: [  575.383331] r8169 0000:03:00.1 eth0:
link up
--[snip]--
Oct  6 14:11:59 shelf kernel: [  691.106397] r8169 0000:03:00.1 eth0:
link down
--[snip]--
Oct  6 14:11:59 shelf kernel: [  691.974414] r8169 0000:03:00.1: no
hotplug settings from platform
--[snip]--
Oct  6 14:12:05 shelf kernel: [  697.522170] r8169 0000:03:00.1 eth0:
link up
========================================================

lspci:
-----
00:00.0 Host bridge: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor DRAM Controller (rev 06)
00:02.0 VGA compatible controller: Intel Corporation 4th Gen Core Processor Integrated Graphics Controller (rev 06)
00:03.0 Audio device: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor HD Audio Controller (rev 06)
00:14.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset Family USB xHCI (rev 05)
00:16.0 Communication controller: Intel Corporation 8 Series/C220 Series Chipset Family MEI Controller #1 (rev 04)
00:1a.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset Family USB EHCI #2 (rev 05)
00:1b.0 Audio device: Intel Corporation 8 Series/C220 Series Chipset High Definition Audio Controller (rev 05)
00:1c.0 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Family PCI Express Root Port #1 (rev d5)
00:1c.2 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Family PCI Express Root Port #3 (rev d5)
00:1c.3 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Family PCI Express Root Port #4 (rev d5)
00:1d.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset Family USB EHCI #1 (rev 05)
00:1f.0 ISA bridge: Intel Corporation HM86 Express LPC Controller (rev 05)
00:1f.2 SATA controller: Intel Corporation 8 Series/C220 Series Chipset Family 6-port SATA Controller 1 [AHCI mode] (rev 05)
00:1f.3 SMBus: Intel Corporation 8 Series/C220 Series Chipset Family SMBus Controller (rev 05)
02:00.0 Network controller: Intel Corporation Wireless 7260 (rev 73)
03:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. Device 5287 (rev 01)
03:00.1 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 12)
-----------------------------------------------------------

lspci -v -s 03:00.1:
-------------------

03:00.1 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 12)
	Subsystem: CLEVO/KAPOK Computer Device 5455
	Flags: bus master, fast devsel, latency 0, IRQ 43
	I/O ports at e000 [size=256]
	Memory at f7c14000 (64-bit, non-prefetchable) [size=4K]
	Memory at f7c10000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: r8169
--------------------------------------------------------------------

I have not set the debug parameter on r8169 but can do so if that would
be useful.

ael
