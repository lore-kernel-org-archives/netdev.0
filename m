From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 197015] New: Message at boot
Date: Thu, 21 Sep 2017 08:06:51 -0700
Message-ID: <20170921080651.3c892b5e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:52929 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdIUPG4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:06:56 -0400
Received: by mail-pg0-f49.google.com with SMTP id i195so3652829pgd.9
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 08:06:56 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id b79sm4261075pfd.37.2017.09.21.08.06.55
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Sep 2017 08:06:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 21 Sep 2017 11:45:01 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 197015] New: Message at boot


https://bugzilla.kernel.org/show_bug.cgi?id=197015

            Bug ID: 197015
           Summary: Message at boot
           Product: Networking
           Version: 2.5
    Kernel Version: 4.13.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: jp.pozzi@izzop.net
        Regression: No

Created attachment 258551
  --> https://bugzilla.kernel.org/attachment.cgi?id=258551&action=edit  
.config file

Hello,

I get a message at boot (the system seems to be fully OK including networking),
here is the "dmesg" output :
[   43.514245] ------------[ cut here ]------------
[   43.514249] WARNING: CPU: 5 PID: 40 at net/core/dev.c:5504
net_rx_action+0x213/0x340
[   43.514250] Modules linked in: fuse ebtable_filter ebtables iptable_filter
bridge stp llc snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic
binfmt_misc intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel
kvm ath10k_pci ath10k_core irqbypass crct10dif_pclmul crc32_pclmul i915
ghash_clmulni_intel pcbc mac80211 i2c_designware_platform i2c_designware_core
aesni_intel snd_hda_intel aes_x86_64 crypto_simd glue_helper snd_hda_codec
cryptd intel_uncore snd_hwdep snd_hda_core ath snd_pcm serio_raw snd_timer
pcspkr snd cfg80211 soundcore idma64 iosf_mbi intel_gtt sg intel_lpss_pci
intel_pch_thermal ucsi_acpi typec_ucsi typec intel_lpss_acpi intel_lpss
acpi_pad evdev rtsx_usb mfd_core mq_deadline kyber_iosched deadline_iosched bfq
ip_tables x_tables autofs4 dm_mod dax hid_logitech_hidpp
[   43.514274]  hid_logitech_dj usbhid sd_mod crc32c_intel xhci_pci i2c_i801
xhci_hcd usbcore ahci libahci fan i2c_hid hid
[   43.514279] CPU: 5 PID: 40 Comm: ksoftirqd/5 Not tainted 4.13.2 #1
[   43.514280] Hardware name: Acer Aspire VX5-591G/Wish_KLS, BIOS V1.02
12/28/2016
[   43.514280] task: ffff8c362c79f000 task.stack: ffffa64a401d4000
[   43.514281] RIP: 0010:net_rx_action+0x213/0x340
[   43.514282] RSP: 0018:ffffa64a401d7e18 EFLAGS: 00010297
[   43.514283] RAX: 0000000000000041 RBX: ffff8c363ed5b040 RCX:
ffff8c362b351eb0
[   43.514283] RDX: ffff8c31f44ae000 RSI: 00000000fffffe01 RDI:
ffffffffc081f0f6
[   43.514283] RBP: 000000000000012c R08: 000000046adaad00 R09:
0000000000004ba8
[   43.514284] R10: 0000000000000000 R11: 0000000000000001 R12:
0000000000000010
[   43.514284] R13: 0000000000000041 R14: 0000000000000040 R15:
ffff8c362b357b00
[   43.514285] FS:  0000000000000000(0000) GS:ffff8c363ed40000(0000)
knlGS:0000000000000000
[   43.514286] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   43.514286] CR2: 000056547ac33000 CR3: 0000000463e66000 CR4:
00000000003406e0
[   43.514287] Call Trace:
[   43.514289]  ? __do_softirq+0xff/0x287
[   43.514291]  ? run_ksoftirqd+0x19/0x30
[   43.514293]  ? smpboot_thread_fn+0xfe/0x150
[   43.514294]  ? kthread+0xf5/0x130
[   43.514295]  ? sort_range+0x20/0x20
[   43.514296]  ? kthread_park+0x60/0x60
[   43.514297]  ? ret_from_fork+0x22/0x30
[   43.514297] Code: 00 48 83 c4 30 5b 5d 41 5c 41 5d 41 5e 41 5f c3 44 89 f6
4c 89 ff 41 ff 57 20 41 89 c5 0f 1f 44 00 00 45 39 ee 0f 8d e3 fe ff ff <0f> ff
45 39 ee 0f 8f e1 fe ff ff 49 8b 47 10 a8 04 0f 85 c9 00 
[   43.514311] ---[ end trace 5bb8c0b36979bc7c ]---
[  128.084356] ntfs: driver 2.1.32 [Flags: R/W MODULE].
--------------------------------------------------------------------------------
I enclose the .config file

Regards

JP P

-- 
You are receiving this mail because:
You are the assignee for the bug.
