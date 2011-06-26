From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39.2 BUG: unable to handle kernel NULL pointer dereference
Date: Sun, 26 Jun 2011 11:56:12 +0200
Message-ID: <1309082172.2532.31.camel@edumazet-laptop>
References: <BANLkTing9LWO6AjbdzOJzkJ9aoJhn_TLnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Fabio Coatti <fabio.coatti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTing9LWO6AjbdzOJzkJ9aoJhn_TLnw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 26 juin 2011 =C3=A0 10:28 +0200, Fabio Coatti a =C3=A9crit =
:
> I'm trying to boot with 2.6.39.2 but the process stops somewhere in
> network stack, with a BUG: report.
> I've been able to capture the kernel messages usign netconsole, so be
> patient with poor alignment :)
>=20
> Please note that at this moment I'm not subscribed to LKML, so please
> keep me in CC if any answer is required. Below you can find the
> netconsole trace and .config file.
>=20
> Thanks for the attention.
>=20
>=20
> ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 11 14 15) *0, disabled=
=2E
> br0: port 1(eth0) entering forwarding state
> i8042: PNP: No PS/2 controller found. Probing ports directly.
> serio: i8042 KBD port at 0x60,0x64 irq 1
> serio: i8042 AUX port at 0x60,0x64 irq 12
> mousedev: PS/2 mouse device common for all mice
> rtc_cmos 00:05: RTC can wake from S4
> rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
> rtc0: alarms up to one year, y3k, 242 bytes nvram, hpet irqs
> md: linear personality registered for level -1
> md: raid0 personality registered for level 0
> md: raid1 personality registered for level 1
> md: raid10 personality registered for level 10
> md: raid6 personality registered for level 6
> md: raid5 personality registered for level 5
> md: raid4 personality registered for level 4
> md: multipath personality registered for level -4
> device-mapper: uevent: version 1.0.3
> device-mapper: ioctl: 4.20.0-ioctl (2011-02-02) initialised: dm-devel=
@redhat.com
> cpuidle: using governor ladder
> Netfilter messages via NETLINK v0.30.
> TCP cubic registered
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> Registering the dns_resolver key type
> rtc_cmos 00:05: setting system clock to 2011-06-26 08:10:48 UTC (1309=
075848)
> Freeing unused kernel memory: 6372k freed
> BUG: unable to handle kernel
> NULL pointer dereference
> at           (null)
> IP:
> [<          (null)>]           (null)
> PGD 230a57067
> PUD 2309fb067
> PMD 0
>=20
> Oops: 0010 [#1]
> PREEMPT
> SMP
>=20
> last sysfs file: /sys/devices/virtual/net/br0/uevent
> CPU 2
>=20
> Modules linked in:
> bridge
> stp
> llc
> ip6t_rt
> ip6table_filter
> ip6_tables
> x_tables
> snd_usb_audio
> uvcvideo
> videodev
> snd_usbmidi_lib
> v4l2_compat_ioctl32
> snd_rawmidi
> snd_seq_device
> hid_logitech
> ipv6
> usbhid
> usb_storage
> usb_libusual
> uas
> snd_hda_codec_hdmi
> snd_hda_codec_analog
> ohci_hcd
> ehci_hcd
> snd_hda_intel
> snd_hda_codec
> k10temp
> i2c_nforce2
> snd_hwdep
> snd_pcm
> asus_atk0110
> snd_timer
> snd
> usbcore
> soundcore
> snd_page_alloc
>=20
>=20
> Pid: 3359, comm: ip Tainted: G        W   2.6.39.2 #2
> System manufacturer System Product Name
> /M3N-HT DELUXE
>=20
> RIP: 0010:[<0000000000000000>]
> [<          (null)>]           (null)
> RSP: 0018:ffff8802264398a0  EFLAGS: 00010202
> RAX: 00000000000005dc RBX: 0000000000000320 RCX: ffff88022d38e608
> RDX: ffffffffa01d6fc0 RSI: ffffffffa01d5c61 RDI: ffff88022d38ee38
> RBP: ffff88022d38e000 R08: 0000000000000000 R09: ffff880230a5bb80
> R10: ffffffff81353339 R11: 0000000000000000 R12: ffff88022d38e600
> R13: 0000000000000000 R14: 0000000000000000 R15: ffffffffa01d5870
> FS:  00007f4e5bb98700(0000) GS:ffff88023fd00000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000000 CR3: 000000022640b000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process ip (pid: 3359, threadinfo ffff880226438000, task ffff880230ad=
e300)
> Stack:
> ffffffffa01cc1e7
> ffff88022d38e000
> ffff8802264399a8
> 0000000000000000
>=20
> ffffffff8135bd0f
> ffff88022d38e000
> ffffffff81366ab9
> ffff88022d38e000
>=20
> ffff88022a4cfc10
> ffff880226439ae8
> 00000009a0124919
> ffff88022d39ed00
>=20
> Call Trace:
> [<ffffffffa01cc1e7>] ? br_change_mtu+0x50/0x6f [bridge]
> [<ffffffff8135bd0f>] ? dev_set_mtu+0x35/0x5b
> [<ffffffff81366ab9>] ? do_setlink+0x189/0x706
> [<ffffffff81365cfd>] ? rtnl_fill_ifinfo+0x954/0xa20
> [<ffffffff810925fd>] ? handle_mm_fault+0x107/0x189
> [<ffffffff8136738d>] ? rtnl_newlink+0x26a/0x4c1
> [<ffffffff813671d3>] ? rtnl_newlink+0xb0/0x4c1
> [<ffffffff813d7ead>] ? _raw_spin_unlock_irqrestore+0x20/0x2e
> [<ffffffff813553dc>] ? __skb_recv_datagram+0x103/0x23f
> [<ffffffff81366437>] ? rtnetlink_rcv+0x28/0x28
> [<ffffffff8137744b>] ? netlink_rcv_skb+0x34/0x7d
> [<ffffffff8136642e>] ? rtnetlink_rcv+0x1f/0x28
> [<ffffffff81377239>] ? netlink_unicast+0xe5/0x14d
> [<ffffffff813776da>] ? netlink_sendmsg+0x246/0x266
> [<ffffffff8134a6bb>] ? sock_sendmsg+0x83/0x9b
> [<ffffffff81091332>] ? __do_fault+0x396/0x3d1
> [<ffffffff8134a49f>] ? move_addr_to_kernel+0x2c/0x4a
> [<ffffffff8135463f>] ? verify_iovec+0x46/0x98
> [<ffffffff8134aae5>] ? sys_sendmsg+0x22c/0x2b4
> [<ffffffff810925fd>] ? handle_mm_fault+0x107/0x189
> [<ffffffff8101a773>] ? do_page_fault+0x29b/0x2d4
> [<ffffffff810960d3>] ? do_brk+0x2ca/0x326
> [<ffffffff813d887b>] ? system_call_fastpath+0x16/0x1b
> Code:
> Bad RIP value.
>=20
> RIP
> [<          (null)>]           (null)
> RSP <ffff8802264398a0>
> CR2: 0000000000000000
> ---[ end trace c2ce621f7ff96fed ]---
> br0: no IPv6 routers present
> br0: port 1(eth0) entering forwarding state
>=20
>=20

Hi Fabio

Could you test following patch :=20

http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D6407d74c5106bb362b4087693688afd34942b094


This should be included in 2.6.39.3, if you confirm this fixes the
problem.
