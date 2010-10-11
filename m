From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 19942] New: Not a intel bug:
 kernel BUG at drivers/pci/intel-iommu.c:1656
Date: Mon, 11 Oct 2010 13:45:26 -0700
Message-ID: <20101011134526.8823a1a3.akpm@linux-foundation.org>
References: <bug-19942-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	Jesse Barnes <jbarnes@virtuousgeek.org>, bugme-daemon@bugzilla.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
To: gronslet@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-19942-10286@https.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).


On Sat, 9 Oct 2010 10:07:15 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=19942
> 
>            Summary: Not a intel bug: kernel BUG at
>                     drivers/pci/intel-iommu.c:1656
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36-0.35.rc7.git0.fc15.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: gronslet@gmail.com
>         Regression: No
> 
> 
> On my Fedora Rawhide system, I keep getting these errors, which kills my wifi
> and require me to reboot my Lenovo Thinkpad T400. Please also see
> https://bugzilla.redhat.com/show_bug.cgi?id=637554
> https://bugs.freedesktop.org/show_bug.cgi?id=30722
> 
> In the latter, I was asked to file the bug here, as it isn't a intel bug.
> Fedora Rawhide, kernel-2.6.36-0.35.rc7.git0.fc15.x86_64,
> xorg-x11-drv-intel-2.12.0-6.fc14.1.x86_64, xorg-x11-drivers-7.4-1.fc14.x86_64
> xorg-x11-server-utils-7.4-20.fc15.x86_64,
> NetworkManager-0.8.1-7.git20100831.fc15.x86_64
> 
> This happens when I resume my laptop after suspend to ram:
> 
> [24572.218077] PM: resume devices took 0.987 seconds
> [24572.239068] PM: Finishing wakeup.
> [24572.239216] Restarting tasks ... 
> [24572.239332] usb 2-4: USB disconnect, address 2
> [24572.245520] done.
> [24572.245702] video LNXVIDEO:00: Restoring backlight state
> [24572.249109] ehci_hcd 0000:00:1d.7: dma_pool_free buffer-2048,
> ffff880134f9d000/ffffb000 (bad dma)
> [24572.249631] ehci_hcd 0000:00:1d.7: dma_pool_free buffer-2048,
> ffff880134f9d080/ffffb080 (bad dma)
> [24572.249977] cdc_ether 2-4:1.7: wwan0: unregister 'cdc_ether'
> usb-0000:00:1d.7-4, Mobile Broadband Network Device
> [24573.685674] ------------[ cut here ]------------
> [24573.685709] kernel BUG at drivers/pci/intel-iommu.c:1656!
> [24573.685734] invalid opcode: 0000 [#1] SMP 
> [24573.685761] last sysfs file: /sys/devices/system/cpu/sched_mc_power_savings
> [24573.685791] CPU 0 
> [24573.685803] Modules linked in: rfcomm sunrpc sco bnep l2cap cpufreq_ondemand
> acpi_cpufreq freq_table mperf ip6t_REJECT xt_physdev nf_conntrack_ipv6
> ip6table_filter ipt_MASQUERADE iptable_nat ip6_tables nf_nat sha256_generic
> cryptd aes_x86_64 aes_generic cbc dm_crypt uinput arc4 ecb
> snd_hda_codec_conexant snd_hda_intel iwlagn snd_hda_codec snd_hwdep zaurus
> iwlcore snd_seq snd_seq_device r852 sm_common cdc_ether nand nand_ids nand_ecc
> microcode mac80211 uvcvideo usbnet mtd mii cdc_acm snd_pcm btusb cdc_wdm
> bluetooth videodev iTCO_wdt i2c_i801 iTCO_vendor_support joydev cfg80211
> thinkpad_acpi v4l1_compat v4l2_compat_ioctl32 e1000e snd_timer rfkill
> snd_page_alloc wmi snd soundcore ipv6 sdhci_pci sdhci firewire_ohci mmc_core
> firewire_core yenta_socket crc_itu_t i915 drm_kms_helper drm i2c_algo_bit
> i2c_core video output [last unloaded: scsi_wait_scan]
> [24573.686007] 
> [24573.686007] Pid: 8321, comm: NetworkManager Not tainted
> 2.6.36-0.35.rc7.git0.fc15.x86_64 #1 6474AR4/6474AR4
> [24573.686007] RIP: 0010:[<ffffffff8126ea48>]  [<ffffffff8126ea48>]
> __domain_mapping+0x43/0x1ce
> [24573.686007] RSP: 0018:ffff880133727648  EFLAGS: 00010206
> [24573.694051] RAX: 0000000001ffffff RBX: ffff8800b4687400 RCX:
> 000000000000001b
> [24573.694051] RDX: 000000000008b621 RSI: 000ffffffffffdff RDI:
> ffff8801320f6dc0
> [24573.694051] RBP: ffff880133727698 R08: 0000000000000001 R09:
> 0000000000000003
> [24573.694051] R10: ffff8801320f6df8 R11: 0000000000000000 R12:
> 0000000000000000
> [24573.694051] R13: ffff8801320f6dc0 R14: ffff88013bc04ff8 R15:
> 0000000000000001
> [24573.694051] FS:  00007fb24c872800(0000) GS:ffff880002c00000(0000)
> knlGS:0000000000000000
> [24573.694051] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [24573.694051] CR2: 000000000042da00 CR3: 000000012fbc2000 CR4:
> 00000000000006f0
> [24573.694051] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [24573.694051] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [24573.694051] Process NetworkManager (pid: 8321, threadinfo ffff880133726000,
> task ffff88012f8f0000)
> [24573.694051] Stack:
> [24573.694051]  ffff88013707e240 ffff8801320f6dc0 ffff880133727698
> 000ffffffffffdff
> [24573.694051] <0> 0000000000000000 ffff8800b4687400 000000008b621000
> ffff8801320f6dc0
> [24573.694051] <0> ffff88013bc04ff8 0000000000000000 ffff8801337276f8
> ffffffff8126f710
> [24573.694051] Call Trace:
> [24573.694051]  [<ffffffff8126f710>] __intel_map_single.clone.25+0xdc/0x16b
> [24573.694051]  [<ffffffff8126f88c>] intel_alloc_coherent+0xae/0xd5
> [24573.694051]  [<ffffffffa018c128>] e1000_alloc_ring_dma.clone.28+0x94/0xc0
> [e1000e]
> [24573.694051]  [<ffffffffa018e359>] e1000e_setup_tx_resources+0x65/0xaa
> [e1000e]
> [24573.694051]  [<ffffffffa018e891>] e1000_open+0x64/0x41e [e1000e]
> [24573.694051]  [<ffffffff813eeb45>] __dev_open+0x9b/0xd2
> [24573.694051]  [<ffffffff813eed87>] __dev_change_flags+0xad/0x130
> [24573.694051]  [<ffffffff813eee8b>] dev_change_flags+0x21/0x56
> [24573.694051]  [<ffffffff813f90f9>] do_setlink+0x2ba/0x61f
> [24573.694051]  [<ffffffff8107d8c7>] ? print_lock_contention_bug+0x1b/0xd5
> [24573.694051]  [<ffffffff81249f7f>] ? debug_check_no_obj_freed+0x65/0x18a
> [24573.694051]  [<ffffffff8107d8c7>] ? print_lock_contention_bug+0x1b/0xd5
> [24573.694051]  [<ffffffff813f96be>] rtnl_setlink+0xd0/0xf2
> [24573.694051]  [<ffffffff813f99ac>] rtnetlink_rcv_msg+0x1eb/0x201
> [24573.694051]  [<ffffffff813f97c1>] ? rtnetlink_rcv_msg+0x0/0x201
> [24573.694051]  [<ffffffff8140d3e5>] netlink_rcv_skb+0x45/0x90
> [24573.694051]  [<ffffffff813f8d29>] rtnetlink_rcv+0x26/0x2d
> [24573.694051]  [<ffffffff8140cec0>] netlink_unicast+0xee/0x157
> [24573.694051]  [<ffffffff8140d1e1>] netlink_sendmsg+0x2b8/0x2d6
> [24573.694051]  [<ffffffff813da64e>] __sock_sendmsg+0x6b/0x77
> [24573.694051]  [<ffffffff813da9a8>] sock_sendmsg+0xa8/0xc1
> [24573.694051]  [<ffffffff8107ff07>] ? lock_acquire+0xee/0xfd
> [24573.694051]  [<ffffffff810fb080>] ? might_fault+0x5c/0xac
> [24573.694051]  [<ffffffff8107fe0d>] ? lock_release+0x19a/0x1a6
> [24573.694051]  [<ffffffff810fb0c9>] ? might_fault+0xa5/0xac
> [24573.694051]  [<ffffffff813e4dbb>] ? copy_from_user+0x2f/0x31
> [24573.694051]  [<ffffffff813e51ae>] ? verify_iovec+0x57/0x99
> [24573.694051]  [<ffffffff813dc971>] sys_sendmsg+0x235/0x2b3
> [24573.694051]  [<ffffffff8112bb26>] ? rcu_read_lock+0x0/0x35
> [24573.694051]  [<ffffffff8107ff07>] ? lock_acquire+0xee/0xfd
> [24573.694051]  [<ffffffff8112bb26>] ? rcu_read_lock+0x0/0x35
> [24573.694051]  [<ffffffff813dc405>] ? sys_sendto+0x125/0x152
> [24573.694051]  [<ffffffff8112c5a2>] ? fput+0x22/0x1d6
> [24573.694051]  [<ffffffff8112c4ae>] ? fget_light+0x79/0x83
> [24573.694051]  [<ffffffff81133e5b>] ? path_put+0x22/0x27
> [24573.694051]  [<ffffffff810a8443>] ? audit_syscall_entry+0x11c/0x148
> [24573.694051]  [<ffffffff8149da45>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [24573.694051]  [<ffffffff81009cf2>] system_call_fastpath+0x16/0x1b
> [24573.694051] Code: d4 48 89 ca 48 89 7d b8 6b 8f 84 00 00 00 09 48 89 75 c8
> 4d 89 c7 83 c1 12 83 f9 3f 7f 0f 4a 8d 44 06 ff 48 d3 e8 48 85 c0 74 02 <0f> 0b
> 41 f6 c1 03 b8 ea ff ff ff 0f 84 6b 01 00 00 41 81 e1 03 
> [24573.694051] RIP  [<ffffffff8126ea48>] __domain_mapping+0x43/0x1ce
> [24573.694051]  RSP <ffff880133727648>
> [24573.821392] ---[ end trace 391efc8948e1496b ]---
> [24573.832050] NetworkManager used greatest stack depth: 2064 bytes left
> [24574.026042] usb 4-2: new full speed USB device using uhci_hcd and address 3
> [24574.187102] usb 4-2: New USB device found, idVendor=0a5c, idProduct=2145
> [24574.188244] usb 4-2: New USB device strings: Mfr=1, Product=2,
> SerialNumber=0
> [24574.189418] usb 4-2: Product: ThinkPad Bluetooth with Enhanced Data Rate II
> [24574.190567] usb 4-2: Manufacturer: Lenovo Computer Corp
> [24576.230085] usb 2-4: new high speed USB device using ehci_hcd and address 3
> [24577.080715] usb 2-4: New USB device found, idVendor=0bdb, idProduct=1900
> [24577.081862] usb 2-4: New USB device strings: Mfr=1, Product=2,
> SerialNumber=3
> [24577.083009] usb 2-4: Product: Ericsson F3507g Mobile Broadband Minicard
> Composite Device
> [24577.084140] usb 2-4: Manufacturer: Ericsson
> [24577.085263] usb 2-4: SerialNumber: 3541430207407750
> [24577.144202] cdc_acm 2-4:1.1: ttyACM0: USB ACM device
> [24577.163044] cdc_acm 2-4:1.3: ttyACM1: USB ACM device
> [24577.174389] cdc_wdm 2-4:1.5: cdc-wdm0: USB WDM device
> [24577.183588] cdc_wdm 2-4:1.6: cdc-wdm1: USB WDM device
> [26974.894966] thinkpad_acpi: EC reports that Thermal Table has changed
> 
> 
> Note that I explicitly have disabled iommu for intel:
> # cat /proc/cmdline 
> ro root=/dev/VolGroup00/lv_root rhgb quiet selinux=0 vga=0x318
> SYSFONT=latarcyrheb-sun16 LANG=en_US.UTF-8 KEYTABLE=no intel_iommu=igfx_off
> 
> I've seen this on 2.6.36-0.35.rc7.git0.fc15.x86_64,
> 2.6.36-0.27.rc5.git6.fc15.x86_64,2.6.36-0.32.rc6.git2.fc15.x86_64.

I don't have any of those kernel versions here, but I'm guessing that
this test is triggering:

	BUG_ON(addr_width < BITS_PER_LONG && (iov_pfn + nr_pages - 1) >> addr_width);

It could be that e1000e is feeding in garbage, or it could be that
intel-iommu is screwed up.


It's a bit hard to tell what's happening because that BUG_ON was quite
poorly thought out.  It tests three different variables, doesn't tell
us their values and even though it _could_ cleanly recover and allow
the machine to continue to operate it simply whacks the box.

So we now have a pickle on our hands, because you use prebuilt kernels
and are probably not in a position to test patches.  


------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today.
http://p.sf.net/sfu/beautyoftheweb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
