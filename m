From: Jesper Juhl <jj@chaosbits.net>
Subject: WARNING: at drivers/net/e1000e/netdev.c:5221 __e1000_shutdown+0x43f/0x4c0
 [e1000e]()
Date: Thu, 4 Aug 2011 10:24:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1108041013390.7617@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I just woke my laptop from suspend and found this in dmesg :

...
[46011.457402] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
[46011.457407] e1000e 0000:00:19.0: eth0: 10/100 speed: disabling TSO
[46011.457808] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[46011.465085] hub 1-1.2:1.0: USB hub found
[46011.465482] hub 1-1.2:1.0: 4 ports detected
[46011.731642] usb 1-1.2.3: new low speed USB device number 11 using ehci_hcd
[46011.823432] input: USB Mouse as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2.3/1-1.2.3:1.0/input/input14
[46011.823546] generic-usb 0003:0566:4006.0005: input,hidraw0: USB HID v1.11 Mouse [USB Mouse] on usb-0000:00:1a.0-1.2.3/input0
[46011.901235] usb 1-1.2.4: new full speed USB device number 12 using ehci_hcd
[46012.017545] input: Sun USB Keyboard as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2.4/1-1.2.4:1.0/input/input15
[46012.017786] generic-usb 0003:0430:00A2.0006: input,hidraw1: USB HID v1.10 Keyboard [Sun USB Keyboard] on usb-0000:00:1a.0-1.2.4/input0
[46013.437900] e1000e 0000:00:19.0: PME# enabled
[46013.467170] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf2600000-0xf261ffff] (PCI address [0xf2600000-0xf261ffff])
[46013.467182] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf2625000-0xf2625fff] (PCI address [0xf2625000-0xf2625fff])
[46013.467191] e1000e 0000:00:19.0: BAR 2: set to [io  0x1820-0x183f] (PCI address [0x1820-0x183f])
[46013.467214] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[46013.467241] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[46013.467305] e1000e 0000:00:19.0: PME# disabled
[46013.560412] e1000e 0000:00:19.0: irq 41 for MSI/MSI-X
[46013.613523] e1000e 0000:00:19.0: irq 41 for MSI/MSI-X
[46013.614823] ADDRCONF(NETDEV_UP): eth0: link is not ready
[46013.750226] e1000e 0000:00:19.0: PME# enabled
[46013.786332] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf2600000-0xf261ffff] (PCI address [0xf2600000-0xf261ffff])
[46013.786344] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf2625000-0xf2625fff] (PCI address [0xf2625000-0xf2625fff])
[46013.786354] e1000e 0000:00:19.0: BAR 2: set to [io  0x1820-0x183f] (PCI address [0x1820-0x183f])
[46013.786377] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[46013.786405] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100507)
[46013.786467] e1000e 0000:00:19.0: PME# disabled
[46013.879654] e1000e 0000:00:19.0: irq 41 for MSI/MSI-X
[46013.932698] e1000e 0000:00:19.0: irq 41 for MSI/MSI-X
[46013.933919] ADDRCONF(NETDEV_UP): eth0: link is not ready
[46014.933488] ------------[ cut here ]------------
[46014.933522] WARNING: at drivers/net/e1000e/netdev.c:5221 __e1000_shutdown+0x43f/0x4c0 [e1000e]()
[46014.933526] Hardware name: 4384GJG
[46014.933529] Modules linked in: ipv6 usbhid hid uvcvideo videodev media v4l2_compat_ioctl32 snd_hda_codec_hdmi snd_hda_codec_conexant arc4 vboxnetadp vboxnetflt snd_hda_intel vboxdrv ecb i915 drm_kms_helper snd_hda_codec iwlagn snd_hwdep drm serio_raw sg sdhci_pci mac80211 firewire_ohci cfg80211 snd_pcm ehci_hcd tpm_tis usbcore sdhci cpufreq_ondemand firewire_core battery snd_timer mmc_core msr i2c_i801 tpm intel_agp pcspkr psmouse crc_itu_t acpi_cpufreq freq_table e1000e mperf intel_ips wmi i2c_algo_bit tpm_bios evdev intel_gtt i2c_core button thinkpad_acpi processor iTCO_wdt snd_page_alloc ac iTCO_vendor_support video thermal rfkill snd soundcore nvram ext4 mbcache jbd2 crc16 sr_mod cdrom sd_mod ahci libahci libata scsi_mod
[46014.933612] Pid: 29819, comm: kworker/2:1 Not tainted 2.6.39-ARCH #1
[46014.933616] Call Trace:
[46014.933628]  [<ffffffff8105b90f>] warn_slowpath_common+0x7f/0xc0
[46014.933634]  [<ffffffff8105b96a>] warn_slowpath_null+0x1a/0x20
[46014.933643]  [<ffffffffa01c4f7f>] __e1000_shutdown+0x43f/0x4c0 [e1000e]
[46014.933652]  [<ffffffff81012fc9>] ? sched_clock+0x9/0x10
[46014.933656]  [<ffffffffa01c5039>] e1000_runtime_suspend+0x39/0x50 [e1000e]
[46014.933660]  [<ffffffff8100a6cf>] ? __switch_to+0xbf/0x2f0
[46014.933665]  [<ffffffff812392dd>] pci_pm_runtime_suspend+0x4d/0x100
[46014.933667]  [<ffffffff81239290>] ? pci_legacy_suspend_late+0x100/0x100
[46014.933671]  [<ffffffff812e7d52>] rpm_callback+0x42/0x80
[46014.933674]  [<ffffffff813e4faf>] ? schedule+0x33f/0xad0
[46014.933676]  [<ffffffff812e82fa>] rpm_suspend+0x1da/0x3f0
[46014.933679]  [<ffffffff812e9380>] ? pm_schedule_suspend+0xe0/0xe0
[46014.933681]  [<ffffffff812e941a>] pm_runtime_work+0x9a/0xc0
[46014.933685]  [<ffffffff81077f6e>] process_one_work+0x11e/0x4c0
[46014.933687]  [<ffffffff810788ff>] worker_thread+0x15f/0x350
[46014.933689]  [<ffffffff810787a0>] ? manage_workers.isra.29+0x230/0x230
[46014.933694]  [<ffffffff8107d6ec>] kthread+0x8c/0xa0
[46014.933697]  [<ffffffff813e9fe4>] kernel_thread_helper+0x4/0x10
[46014.933699]  [<ffffffff8107d660>] ? kthread_worker_fn+0x190/0x190
[46014.933700]  [<ffffffff813e9fe0>] ? gs_change+0x13/0x13
[46014.933702] ---[ end trace b2e5aa34f74b5252 ]---
[46015.215367] e1000e 0000:00:19.0: PME# enabled
...

This is with a 2.6.39.3 kernel.

The laptop is a Lenovo Thinkpad T510 model 4384-GJG.

lspci -vvx has this to say about the ethernet device:

00:19.0 Ethernet controller: Intel Corporation 82577LM Gigabit Network Connection (rev 06)
        Subsystem: Lenovo Device 2153
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 41
        Region 0: Memory at f2600000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at f2625000 (32-bit, non-prefetchable) [size=4K]
        Region 2: I/O ports at 1820 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME+
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0f00c  Data: 415d
        Capabilities: [e0] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: e1000e
        Kernel modules: e1000e
00: 86 80 ea 10 07 05 10 00 06 00 00 02 00 00 00 00
10: 00 00 60 f2 00 50 62 f2 21 18 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 aa 17 53 21
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0b 01 00 00

The network seems to be working fine, so it's clearly not fatal.
I regularly suspend/resume this laptop and I've never seen this before 
with this or other kernels, so it's not really reproducible.

Let me know if there is other information you'd like and I'll be happy to 
provide it.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
