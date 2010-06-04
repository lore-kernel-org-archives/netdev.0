From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16120] New: Oops: 0000 [#1] SMP, unable to
 handle kernel NULL pointer dereference at (null)
Date: Fri, 4 Jun 2010 16:17:37 -0700
Message-ID: <20100604161737.25c7940a.akpm@linux-foundation.org>
References: <bug-16120-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, alex.vizor@gmail.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60640 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757515Ab0FDXSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 19:18:30 -0400
In-Reply-To: <bug-16120-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 4 Jun 2010 09:25:58 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16120
> 
>            Summary: Oops: 0000 [#1] SMP, unable to handle kernel NULL
>                     pointer dereference at (null)
>            Product: Platform Specific/Hardware
>            Version: 2.5
>     Kernel Version: 2.6.35-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: x86-64
>         AssignedTo: platform_x86_64@kernel-bugs.osdl.org
>         ReportedBy: alex.vizor@gmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=26647)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=26647)
> 2.6.35-rc1 kernel log
> 
> It happens randomly, almost a week I used 2.6.35-rc1 and don't have any
> problems. But since last day it happened twice.
> 
> I attached kernel log, please inform me if I can help in investigation.
> 

ip6mr_sk_done() oopsed.

> [  496.918418] lo: Disabled Privacy Extensions
> [ 1395.335017] lo: Disabled Privacy Extensions
> [ 1396.829424] BUG: unable to handle kernel NULL pointer dereference at (null)
> [ 1396.829430] IP: [<ffffffff8133ac9e>] ip6mr_sk_done+0x5f/0x7b
> [ 1396.829438] PGD 72384067 PUD 6e0b5067 PMD 0 
> [ 1396.829443] Oops: 0000 [#1] SMP 
> [ 1396.829445] last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
> [ 1396.829449] CPU 0 
> [ 1396.829450] Modules linked in: acpi_cpufreq mperf cpufreq_conservative cpufreq_userspace cpufreq_powersave cpufreq_stats autofs4 vboxnetadp vboxnetflt binfmt_misc uinput microcode fuse vboxdrv firewire_sbp2 loop snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss arc4 ecb thinkpad_acpi snd_pcm snd_seq_midi snd_rawmidi iwlagn snd_seq_midi_event r852 iwlcore pcmcia sm_common snd_seq nand snd_timer snd_seq_device nand_ids yenta_socket mac80211 nand_ecc pcmcia_rsrc tpm_tis snd tpm psmouse mtd video soundcore pcmcia_core cfg80211 tpm_bios evdev i2c_i801 nvram pcspkr serio_raw snd_page_alloc wmi output processor battery ac ext4 mbcache jbd2 crc16 ide_cd_mod cdrom sd_mod crc_t10dif ata_generic usbhid hid ata_piix ahci libahci sdhci_pci sdhci firewire_ohci mmc
 _core libata uhci_hcd firewire_core crc_itu_t e1000e led_class piix thermal thermal_sys button ide_core scsi_mod ehci_hcd usbcore nls_base [last unloaded: scsi_wait_scan]
> [ 1396.829514] 
> [ 1396.829517] Pid: 13, comm: netns Not tainted 2.6.35-rc1 #2 64608SG/64608SG
> [ 1396.829519] RIP: 0010:[<ffffffff8133ac9e>]  [<ffffffff8133ac9e>] ip6mr_sk_done+0x5f/0x7b
> [ 1396.829524] RSP: 0018:ffff88007ebf7d40  EFLAGS: 00010296
> [ 1396.829526] RAX: ffff88006c320ce8 RBX: 0000000000000000 RCX: 0000000000000000
> [ 1396.829528] RDX: 0000000000000000 RSI: ffff88006f736508 RDI: ffffffff8167b5a0
> [ 1396.829530] RBP: ffff88006c320880 R08: ffff88006f736480 R09: ffffffff816b0cd0
> [ 1396.829533] R10: ffff88006f736480 R11: ffffffff81313d2e R12: ffff880071c1c800
> [ 1396.829535] R13: ffff88007ebb8da0 R14: ffff88007ebb8da0 R15: ffffffff8167aea8
> [ 1396.829538] FS:  0000000000000000(0000) GS:ffff880001a00000(0000) knlGS:0000000000000000
> [ 1396.829540] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1396.829543] CR2: 0000000000000000 CR3: 0000000071cc3000 CR4: 00000000000006f0
> [ 1396.829545] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1396.829548] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1396.829550] Process netns (pid: 13, threadinfo ffff88007ebf6000, task ffff88007ebb8da0)
> [ 1396.829552] Stack:
> [ 1396.829554]  ffff880071c1c800 ffff88007d9d2280 0000000000000000 ffffffff8132b029
> [ 1396.829557] <0> ffff880071c1c800 ffffffff812f6f15 ffffffff8133adad ffff88007d9d2280
> [ 1396.829561] <0> 0000000000000000 ffffffff8129d5c8 ffff880001a108d0 ffff880071c1c800
> [ 1396.829565] Call Trace:
> [ 1396.829570]  [<ffffffff8132b029>] ? rawv6_close+0x1f/0x28
> [ 1396.829575]  [<ffffffff812f6f15>] ? inet_release+0x6d/0x73
> [ 1396.829579]  [<ffffffff8133adad>] ? ip6mr_rules_exit+0x3c/0x59
> [ 1396.829584]  [<ffffffff8129d5c8>] ? sock_release+0x19/0x6b
> [ 1396.829587]  [<ffffffff812a1729>] ? sk_release_kernel+0x23/0x48
> [ 1396.829591]  [<ffffffff8132bd49>] ? icmpv6_sk_exit+0x20/0x4e
> [ 1396.829595]  [<ffffffff812a8bfc>] ? ops_exit_list+0x1c/0x4b
> [ 1396.829598]  [<ffffffff812a8efa>] ? cleanup_net+0xf8/0x191
> [ 1396.829603]  [<ffffffff810594c0>] ? worker_thread+0x19c/0x22a
> [ 1396.829607]  [<ffffffff81359ea8>] ? schedule+0x4ab/0x507
> [ 1396.829610]  [<ffffffff812a8e02>] ? cleanup_net+0x0/0x191
> [ 1396.829615]  [<ffffffff8105cd79>] ? autoremove_wake_function+0x0/0x2a
> [ 1396.829618]  [<ffffffff81059324>] ? worker_thread+0x0/0x22a
> [ 1396.829622]  [<ffffffff8105c925>] ? kthread+0x75/0x7d
> [ 1396.829626]  [<ffffffff810097e4>] ? kernel_thread_helper+0x4/0x10
> [ 1396.829630]  [<ffffffff8105c8b0>] ? kthread+0x0/0x7d
> [ 1396.829633]  [<ffffffff810097e0>] ? kernel_thread_helper+0x0/0x10
> [ 1396.829635] Code: 43 20 00 00 00 00 48 8b 85 f0 02 00 00 48 c7 c7 10 43 68 81 ff 48 64 e8 e2 06 02 00 48 89 df 31 db e8 47 fe ff ff eb 13 48 8b 1b <48> 8b 13 48 39 c3 0f 18 0a 75 b6 bb f3 ff ff ff e8 49 cb f7 ff 
> [ 1396.829662] RIP  [<ffffffff8133ac9e>] ip6mr_sk_done+0x5f/0x7b
> [ 1396.829665]  RSP <ffff88007ebf7d40>
> [ 1396.829667] CR2: 0000000000000000
> [ 1396.829669] ---[ end trace e8367210bb17519d ]---
> 
