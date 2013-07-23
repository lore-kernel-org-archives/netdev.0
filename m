From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60607] New: After pppd goes down the kernel oops'ed
Date: Tue, 23 Jul 2013 15:14:57 -0700
Message-ID: <20130723151457.189f8b41@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f65.google.com ([209.85.160.65]:54747 "EHLO
	mail-pb0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933460Ab3GWWPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 18:15:00 -0400
Received: by mail-pb0-f65.google.com with SMTP id un1so3784295pbc.0
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 15:15:00 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id zf3sm47426162pac.9.2013.07.23.15.14.59
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 23 Jul 2013 15:14:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 22 Jul 2013 20:35:39 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60607] New: After pppd goes down the kernel oops'ed


https://bugzilla.kernel.org/show_bug.cgi?id=60607

            Bug ID: 60607
           Summary: After pppd goes down the kernel oops'ed
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.1 and 3.10.2
          Hardware: i386
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: diamondjoe18640@yahoo.com
        Regression: No

Jul 22 22:33:27 ltros pppd[3513]: Connect: ppp0 <--> /dev/tts/0
Jul 22 22:33:27 ltros pppd[3513]: sent [LCP ConfReq id=0x1 <asyncmap 0x0>
<magic 0x62eae411> <pcomp> <accomp>]
Jul 22 22:33:27 ltros pppd[3513]: Terminating on signal 15
Jul 22 22:33:27 ltros pppd[3513]: sent [LCP TermReq id=0x2 "User request"]
Jul 22 22:33:29 ltros kernel: BUG: unable to handle kernel NULL pointer
dereference at 00000014
Jul 22 22:33:29 ltros kernel: IP: [<e10a82e7>] ppp_register_channel+0x10/0x1a
[ppp_generic]
Jul 22 22:33:29 ltros kernel: *pde = 00000000
Jul 22 22:33:29 ltros kernel: Oops: 0000 [#1] PREEMPT
Jul 22 22:33:29 ltros kernel: Modules linked in: usb_storage ppp_async
crc_ccitt ppp_generic slhc nvidia_agp drm dm_mod snd_
seq_oss snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss fuse dcdbas
ehci_pci snd_emu10k1 snd_rawmidi snd_ac97_codec ac9
7_bus snd_pcm snd_seq_device snd_timer snd_page_alloc snd_util_mem snd_hwdep
snd ehci_hcd uhci_hcd intel_agp intel_gtt i2c_i
801 usbcore usb_common agpgart
Jul 22 22:33:29 ltros kernel: CPU: 0 PID: 3513 Comm: pppd Not tainted 3.10.2 #1
Jul 22 22:33:29 ltros kernel: Hardware name: Dell Computer Corporation      
XPS-Z                          /D815EEA
                , BIOS A11 06/11/2002
Jul 22 22:33:29 ltros kernel: task: ccdd0da0 ti: ccca2000 task.ti: ccca2000
Jul 22 22:33:29 ltros kernel: EIP: 0060:[<e10a82e7>] EFLAGS: 00010293 CPU: 0
Jul 22 22:33:29 ltros kernel: EIP is at ppp_register_channel+0x10/0x1a
[ppp_generic]
Jul 22 22:33:29 ltros kernel: EAX: 00000000 EBX: ccfc8000 ECX: df782a4c EDX:
ccfc8094
Jul 22 22:33:29 ltros kernel: ESI: fffffff4 EDI: df782a00 EBP: ccca3d98 ESP:
ccca3d98
Jul 22 22:33:29 ltros kernel:  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Jul 22 22:33:29 ltros kernel: CR0: 8005003b CR2: 00000014 CR3: 1f6c9000 CR4:
000007d0
Jul 22 22:33:29 ltros kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3:
00000000
Jul 22 22:33:29 ltros kernel: DR6: ffff0ff0 DR7: 00000400
Jul 22 22:33:29 ltros kernel: Stack:
Jul 22 22:33:29 ltros kernel:  ccca3db8 e10baa41 00000000 ccfc808c ccfc808c
df782a00 ccdb6ec0 df782a00
Jul 22 22:33:29 ltros kernel:  ccca3dc8 c116e152 df782a18 ccdd0da0 ccca3e30
c116e7f4 00000000 00000296
Jul 22 22:33:29 ltros kernel:  00000001 00000000 00000296 00000000 00000001
ccdd0da0 ccca3e0c c102fe16
Jul 22 22:33:29 ltros kernel: Call Trace:
Jul 22 22:33:29 ltros kernel:  [<e10baa41>] ppp_asynctty_open+0xed/0x116
[ppp_async]
Jul 22 22:33:29 ltros kernel:  [<c116e152>] tty_ldisc_open+0x35/0x44
Jul 22 22:33:29 ltros kernel:  [<c116e7f4>] tty_ldisc_hangup+0x159/0x1e5
Jul 22 22:33:29 ltros kernel:  [<c102fe16>] ? group_send_sig_info+0x3e/0x4b
Jul 22 22:33:29 ltros kernel:  [<c102ff84>] ? __kill_pgrp_info+0x3c/0x67
Jul 22 22:33:29 ltros kernel:  [<c116872f>] __tty_hangup+0x265/0x329
Jul 22 22:33:29 ltros kernel:  [<c1168839>] disassociate_ctty+0x46/0x1ca
Jul 22 22:33:29 ltros kernel:  [<c10283db>] do_exit+0x28c/0x6d9
Jul 22 22:33:29 ltros kernel:  [<c102eb64>] ? recalc_sigpending+0x11/0x37
Jul 22 22:33:29 ltros kernel:  [<c102888b>] do_group_exit+0x63/0x86
Jul 22 22:33:29 ltros kernel:  [<c103117f>] get_signal_to_deliver+0x47d/0x4a3
Jul 22 22:33:29 ltros kernel:  [<c1000fd6>] do_notify_resume+0x4c/0x436
Jul 22 22:33:29 ltros kernel:  [<e10a80a1>] ? ppp_xmit_process+0x494/0x4a8
[ppp_generic]
Jul 22 22:33:29 ltros kernel:  [<c1092151>] ?
poll_select_copy_remaining+0xb2/0xce
Jul 22 22:33:29 ltros kernel:  [<c1093385>] ? SyS_select+0x94/0xa3
Jul 22 22:33:29 ltros kernel:  [<c129438b>] work_notifysig+0x24/0x29
Jul 22 22:33:29 ltros kernel: Code: 98 08 e8 24 01 f9 df 85 ff 0f 85 6a ff ff
ff e9 61 ff ff ff 5e 5f 5b 5e 5f 5d c3 55 89 c
2 a1 b4 fe 38 c1 8b 80 5c 02 00 00 89 e5 <8b> 40 14 e8 e7 fe ff ff 5d c3 55 8b
90 90 00 00 00 89 e5 ff 82
Jul 22 22:33:29 ltros kernel: EIP: [<e10a82e7>] ppp_register_channel+0x10/0x1a
[ppp_generic] SS:ESP 0068:ccca3d98
Jul 22 22:33:29 ltros kernel: CR2: 0000000000000014
Jul 22 22:33:29 ltros kernel: ---[ end trace f256bd4e340f2b2c ]---
Jul 22 22:33:29 ltros kernel: Fixing recursive fault but reboot is needed!

-- 
You are receiving this mail because:
You are the assignee for the bug.
