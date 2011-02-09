From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Linux 2.6.38-rc4 (hysdn: BUG)
Date: Wed, 9 Feb 2011 09:24:19 -0800
Message-ID: <20110209092419.2b335697.randy.dunlap@oracle.com>
References: <AANLkTimmb26UiBSukdNnVdxLJpCGd=QqpCw8vQoHALh-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimmb26UiBSukdNnVdxLJpCGd=QqpCw8vQoHALh-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

on x86_64.  no HYSDN hardware found (correct).
Nearly allmodconfig.


[   65.397577] HYSDN: module Rev: 1.6.6.6 loaded
[   65.397584] HYSDN: network interface Rev: 1.8.6.4 
[   65.398057] HYSDN: 0 card(s) found.
[   65.398121] BUG: unable to handle kernel paging request at ffffffffa06c99f0
[   65.398269] IP: [<ffffffffa06c68ba>] hysdn_getrev+0x2e/0x50 [hysdn]
[   65.398379] PGD 1a14067 PUD 1a18063 PMD 6f6c1067 PTE 800000006ce8c161
[   65.398613] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
[   65.398805] last sysfs file: /sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/irq
[   65.398864] CPU 0 
[   65.398913] Modules linked in: hysdn(+) kernelcapi af_packet nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 cpufreq_ondemand acpi_cpufreq freq_table mperf binfmt_misc dm_mirror dm_region_hash dm_log dm_multipath scsi_dh dm_mod mousedev joydev evdev mac_hid snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_seq usbmouse usbkbd snd_seq_device usbhid snd_pcm hid snd_timer 8250_pnp tg3 pcspkr sr_mod rtc_cmos dcdbas sg snd cdrom i2c_i801 rtc_core iTCO_wdt 8250 processor rtc_lib soundcore iTCO_vendor_support serial_core thermal_sys intel_agp snd_page_alloc intel_gtt button hwmon unix ide_pci_gener
 ic ide_core ata_generic pata_acpi ata_piix sd_mod crc_t10dif ext3 jbd mbcache uhci_hcd ohci_hcd ssb mmc_core pcmcia pcmcia_core firmware_class ehci_hcd usbcore nls_base [last unloaded: micr!
 ocode]
[   65.400030] 
[   65.400030] Pid: 2497, comm: modprobe Not tainted 2.6.38-rc4 #1 0TY565/OptiPlex 745                 
[   65.400030] RIP: 0010:[<ffffffffa06c68ba>]  [<ffffffffa06c68ba>] hysdn_getrev+0x2e/0x50 [hysdn]
[   65.400030] RSP: 0018:ffff88006eec1e68  EFLAGS: 00010206
[   65.400030] RAX: ffffffffa06c99f1 RBX: ffffffffa06c99e9 RCX: ffff88007c4159a0
[   65.400030] RDX: 000000000c960c24 RSI: 0000000000000024 RDI: ffffffffa06c99e9
[   65.400030] RBP: ffff88006eec1e78 R08: 0000000000000000 R09: 0000000000000000
[   65.400030] R10: 0000000000000000 R11: ffffffff8124698c R12: ffff88006eec1e88
[   65.400030] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   65.400030] FS:  00007fe1ae6c76f0(0000) GS:ffff88007c400000(0000) knlGS:0000000000000000
[   65.400030] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   65.400030] CR2: ffffffffa06c99f0 CR3: 000000006eee3000 CR4: 00000000000006f0
[   65.400030] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   65.400030] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   65.400030] Process modprobe (pid: 2497, threadinfo ffff88006eec0000, task ffff88006cf88000)
[   65.400030] Stack:
[   65.400030]  ffff88006eec1e78 0000000000000000 ffff88006eec1eb8 ffffffffa06c3bf8
[   65.400030]  ffff88006cf88000 0000000000000000 0000000000000000 00000000b3346a0d
[   65.400030]  0000000000000000 ffffffffa062b000 ffff88006eec1f18 ffffffffa062b0e2
[   65.400030] Call Trace:
[   65.400030]  [<ffffffffa06c3bf8>] hysdn_procconf_init+0xf5/0x133 [hysdn]
[   65.400030]  [<ffffffffa062b000>] ? hysdn_init+0x0/0x1000 [hysdn]
[   65.400030]  [<ffffffffa062b0e2>] hysdn_init+0xe2/0x1000 [hysdn]
[   65.400030]  [<ffffffff810020e3>] do_one_initcall+0xa9/0x1ef
[   65.400030]  [<ffffffff810d6674>] sys_init_module+0x12b/0x307
[   65.400030]  [<ffffffff8100e942>] system_call_fastpath+0x16/0x1b
[   65.400030] Code: e5 53 48 83 ec 08 0f 1f 44 00 00 be 3a 00 00 00 e8 71 39 c0 e0 48 85 c0 74 1e 48 8d 58 02 be 24 00 00 00 48 89 df e8 5b 39 c0 e0 <c6> 40 ff 00 48 ff 05 db 79 00 00 eb 0e 48 ff 05 da 79 00 00 48 
[   65.400030] RIP  [<ffffffffa06c68ba>] hysdn_getrev+0x2e/0x50 [hysdn]
[   65.400030]  RSP <ffff88006eec1e68>
[   65.400030] CR2: ffffffffa06c99f0
[   65.400030] ---[ end trace bf14fd4acc41f5a9 ]---

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
