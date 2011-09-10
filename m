From: Bart Van Assche <bvanassche@acm.org>
Subject: skge: transmit queue 0 timed out
Date: Sat, 10 Sep 2011 11:27:43 +0200
Message-ID: <CAO+b5-ppHOa72H4D8zoaLTA_tWNdeL5SXo0=aO-4dbbtzgiw5w@mail.gmail.com>
References: <CAO+b5-qVoOOCyUXThinNvGwGudXg0FK-C+aiZ1YMYzKu+Ew0hw@mail.gmail.com>
 <CAO+b5-p=9NXJrT1h6KQG9BpP=mDp8XjMZsCxsk=WkuBZ_KhtKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f43.google.com ([209.85.212.43]:54200 "EHLO
	mail-vw0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab1IJJ2E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2011 05:28:04 -0400
Received: by vws10 with SMTP id 10so2488885vws.2
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2011 02:28:03 -0700 (PDT)
In-Reply-To: <CAO+b5-p=9NXJrT1h6KQG9BpP=mDp8XjMZsCxsk=WkuBZ_KhtKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Anyone who can tell me whether I should worry about the kernel warning
shown below ? I've observed that warning for the first time with
3.1-rc5 and hadn't seen it yet with 3.1-rc4 or any older kernel.

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x24f/0x260()
Hardware name: P5Q DELUXE
NETDEV WATCHDOG: eth0 (skge): transmit queue 0 timed out
Modules linked in: snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device
af_packet rdma_ucm rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_sa
ib_uverbs ib_umad mlx4_ib ib_mad ib_core microcode
cpufreq_conservative cpufreq_userspaceq mperf dm_mod
snd_hda_codec_hdmi snd_hda_codec_analog snd_hda_intel snd_hda_codec
snd_hwdep snd_pcm snd_timer snd sr_mod mlx4_core sg cdrom soundcore
i2c_i801 snd_page_alloc i2c_core pcspkr button uhci_hcd ehci_hcd sxt3
mbcache jbd fan ata_generic ata_piix pata_marvell ahci libahci libata
scsi_mod thermal processor thermal_sys hwmon
Pid: 6260, comm: wish Not tainted 3.1.0-rc4-scst-debug+ #2
Call Trace:
=A0<IRQ>=A0 [<ffffffff8104564f>] warn_slowpath_common+0x7f/0xc0
=A0[<ffffffff81045746>] warn_slowpath_fmt+0x46/0x50
=A0[<ffffffff813268df>] dev_watchdog+0x24f/0x260
=A0[<ffffffff8105602a>] run_timer_softirq+0x19a/0x3f0
=A0[<ffffffff81055f97>] ? run_timer_softirq+0x107/0x3f0
=A0[<ffffffff81326690>] ? pfifo_fast_init+0xa0/0xa0
=A0[<ffffffff8104cecd>] __do_softirq+0xcd/0x250
=A0[<ffffffff813e5cec>] call_softirq+0x1c/0x30
=A0[<ffffffff810043bd>] do_softirq+0x8d/0xc0
=A0[<ffffffff8104d36e>] irq_exit+0xae/0xe0
=A0[<ffffffff813e637e>] smp_apic_timer_interrupt+0x6e/0x99
=A0[<ffffffff813e4570>] apic_timer_interrupt+0x70/0x80
=A0<EOI>=A0 [<ffffffff813dbe0a>] ? retint_swapgs+0xe/0x13
---[ end trace fbbed52d2a66b808 ]---

Bart.
