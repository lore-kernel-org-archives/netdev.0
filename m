From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.37-rc1-git5 -- WARNING: at net/ipv4/devinet.c:137
 in_dev_finish_destroy+0x3d/0x6e()
Date: Mon, 8 Nov 2010 12:06:00 -0800
Message-ID: <20101108200600.GG4032@linux.vnet.ibm.com>
References: <AANLkTinVyf4CpxdzEWUn7zTyOrAMKY3H9Dct-HfopiSD@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>,
	netdev@vger.kernel.org
To: Miles Lane <miles.lane@gmail.com>, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:38715 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab0KHUGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Nov 2010 15:06:03 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTinVyf4CpxdzEWUn7zTyOrAMKY3H9Dct-HfopiSD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 02:56:06PM -0500, Miles Lane wrote:
> WARNING: at net/ipv4/devinet.c:137 in_dev_finish_destroy+0x3d/0x6e()
> Hardware name: UL50VT
> Modules linked in: ipv6 snd_hda_codec_hdmi snd_hda_codec_realtek
> snd_hda_intel snd_hda_codec snd_pcm_oss snd_hwdep snd_mixer_oss
> snd_seq_dummy snd_pcm snd_seq_oss snd_seq_midi iwlagn snd_rawmidi
> snd_seq_midi_event snd_seq iwlcore uvcvideo snd_timer mac80211
> snd_seq_device videodev v4l1_compat v4l2_compat_ioctl32 i915 snd
> rtc_cmos rtc_core psmouse cfg80211 soundcore drm_kms_helper
> snd_page_alloc rtc_lib asus_laptop video battery ac sparse_keymap wmi
> button rfkill processor power_supply led_class usb_storage sg sr_mod
> sd_mod cdrom atl1c ehci_hcd uhci_hcd thermal thermal_sys hwmon
> Pid: 0, comm: kworker/0:0 Not tainted 2.6.37-rc1-git5 #10
> Call Trace:
> =A0<IRQ> =A0[<ffffffff8103767e>] warn_slowpath_common+0x80/0x98
> =A0[<ffffffff810376ab>] warn_slowpath_null+0x15/0x17
> =A0[<ffffffff8130d549>] in_dev_finish_destroy+0x3d/0x6e
> =A0[<ffffffff8130d58e>] in_dev_put+0x14/0x16
> =A0[<ffffffff8130d5ab>] inet_rcu_free_ifa+0x1b/0x27
> =A0[<ffffffff810834a8>] __rcu_process_callbacks+0x1a4/0x2bc
> =A0[<ffffffff8108363b>] rcu_process_callbacks+0x7b/0x82
> =A0[<ffffffff8103cb9c>] __do_softirq+0xb8/0x15a
> =A0[<ffffffff8100394c>] call_softirq+0x1c/0x28
> =A0[<ffffffff81005637>] do_softirq+0x38/0x81
> =A0[<ffffffff8103cce9>] irq_exit+0x45/0x94
> =A0[<ffffffff8101ac1f>] smp_apic_timer_interrupt+0x78/0x86
> =A0[<ffffffff81003413>] apic_timer_interrupt+0x13/0x20
> =A0<EOI> =A0[<ffffffff8134aff6>] ? _raw_spin_unlock_irqrestore+0x3c/0=
x69
> =A0[<ffffffff81059cb3>] clockevents_notify+0x11e/0x12d
> =A0[<ffffffffa008e561>] ? acpi_idle_enter_bm+0x236/0x271 [processor]
> =A0[<ffffffffa008dfce>] lapic_timer_state_broadcast+0x41/0x43 [proces=
sor]
> =A0[<ffffffffa008e588>] acpi_idle_enter_bm+0x25d/0x271 [processor]
> =A0[<ffffffff8129db30>] cpuidle_idle_call+0x9e/0xda
> =A0[<ffffffff810012ea>] cpu_idle+0xce/0x10c
> =A0[<ffffffff81343ce8>] start_secondary+0x1fc/0x205
> ---[ end trace 1d49bc8ff0266634 ]---
> Freeing alive in_device ffff88013fe536d0

Ilpo, thoughts?

							Thanx, Paul
