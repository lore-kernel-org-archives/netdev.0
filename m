From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: 2.6.33-rc5: (e1000): transmit queue 0 timed out
Date: Sat, 23 Jan 2010 23:04:31 +0300
Message-ID: <a4423d671001231204w3e742938u5f1021abb7a5e07c@mail.gmail.com>
References: <a4423d671001230737i3b3c7da1q6cd4ce615888b36e@mail.gmail.com>
	 <201001232052.32230.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:55327 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771Ab0AWUEc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 15:04:32 -0500
Received: by ey-out-2122.google.com with SMTP id d26so587441eyd.19
        for <netdev@vger.kernel.org>; Sat, 23 Jan 2010 12:04:31 -0800 (PST)
In-Reply-To: <201001232052.32230.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 January 2010 22:52, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Saturday 23 January 2010, Alexander Beregalov wrote:
>> Hi
>>
>> It is x86_32, UP
>>
>> e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>> =C2=A0 Tx Queue =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 <0>
>> =C2=A0 TDH =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0<0>
>> =C2=A0 TDT =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0<1f>
>> =C2=A0 next_to_use =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<1f>
>> =C2=A0 next_to_clean =C2=A0 =C2=A0 =C2=A0 =C2=A0<30>
>> buffer_info[next_to_clean]
>> =C2=A0 time_stamp =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 <12d519>
>> =C2=A0 next_to_watch =C2=A0 =C2=A0 =C2=A0 =C2=A0<30>
>> =C2=A0 jiffies =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<12da=
92>
>> =C2=A0 next_to_watch.status <0>
>> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1c5/0x1d0()
>> Hardware name:
>> NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
>> Modules linked in: hwmon_vid sata_sil i2c_nforce2
>> Pid: 0, comm: swapper Not tainted 2.6.33-rc5 #1
>> Call Trace:
>> =C2=A0[<c102a49d>] warn_slowpath_common+0x6d/0xa0
>> =C2=A0[<c12ea885>] ? dev_watchdog+0x1c5/0x1d0
>> =C2=A0[<c12ea885>] ? dev_watchdog+0x1c5/0x1d0
>> =C2=A0[<c102a516>] warn_slowpath_fmt+0x26/0x30
>> =C2=A0[<c12ea885>] dev_watchdog+0x1c5/0x1d0
>> =C2=A0[<c1033bb7>] ? run_timer_softirq+0xd7/0x240
>> =C2=A0[<c1033c31>] run_timer_softirq+0x151/0x240
>> =C2=A0[<c1033bb7>] ? run_timer_softirq+0xd7/0x240
>> =C2=A0[<c12ea6c0>] ? dev_watchdog+0x0/0x1d0
>> =C2=A0[<c102f40a>] __do_softirq+0x7a/0x110
>> =C2=A0[<c102f4ed>] do_softirq+0x4d/0x60
>> =C2=A0[<c102f625>] irq_exit+0x65/0x70
>> =C2=A0[<c1015fe7>] smp_apic_timer_interrupt+0x47/0x80
>> =C2=A0[<c11d6904>] ? trace_hardirqs_off_thunk+0xc/0x18
>> =C2=A0[<c1350e63>] apic_timer_interrupt+0x2f/0x34
>> =C2=A0[<c10088fd>] ? default_idle+0x2d/0x60
>> =C2=A0[<c1001b19>] cpu_idle+0x39/0x60
>> =C2=A0[<c13451e8>] rest_init+0x48/0x50
>> =C2=A0[<c16196b4>] start_kernel+0x26d/0x274
>> =C2=A0[<c1619275>] ? unknown_bootoption+0x0/0x19c
>> =C2=A0[<c1619068>] i386_start_kernel+0x68/0x6e
>> ---[ end trace 828c510cca9472df ]---
>> BUG: unable to handle kernel paging request at 2e8ca4f3
>> IP: [<c1071c51>] put_page+0x11/0x120
>> *pde =3D 00000000
>> Oops: 0000 [#1]
>> last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspe=
ed
>> Modules linked in: hwmon_vid sata_sil i2c_nforce2
>>
>> Pid: 5, comm: events/0 Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A0=
2.6.33-rc5 #1
>> NF7-S/NF7,NF7-V (nVidia-nForce2)/
>> EIP: 0060:[<c1071c51>] EFLAGS: 00010282 CPU: 0
>> EIP is at put_page+0x11/0x120
>> EAX: 2e8ca4f3 EBX: 2e8ca4f3 ECX: 00000000 EDX: ee960640
>> ESI: f6482620 EDI: 000016b0 EBP: f7065ea8 ESP: f7065e98
>> =C2=A0DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>> Process events/0 (pid: 5, ti=3Df7064000 task=3Df70553c0 task.ti=3Df7=
064000)
>> Stack:
>> =C2=A000000206 00000001 f6482620 000016b0 f7065eb8 c12d3100 f6482620=
 f71d9f50
>> <0> f7065ec4 c12d2e32 f80376b0 f7065ecc c12d2ec5 f7065f00 c1276970 c=
ccccccd
>> <0> f7065f00 f711fafc f711fafc f711faa0 00000000 f702b440 000000f2 f=
702b440
>> Call Trace:
>> =C2=A0[<c12d3100>] ? skb_release_data+0x90/0xa0
>> =C2=A0[<c12d2e32>] ? __kfree_skb+0x12/0x90
>> =C2=A0[<c12d2ec5>] ? consume_skb+0x15/0x30
>> =C2=A0[<c1276970>] ? e1000_clean_rx_ring+0x80/0x150
>> =C2=A0[<c127c743>] ? e1000_down+0x1b3/0x1d0
>> =C2=A0[<c127cf60>] ? e1000_reset_task+0x0/0x10
>> =C2=A0[<c127cd3b>] ? e1000_reinit_locked+0x4b/0x70
>> =C2=A0[<c127cf6d>] ? e1000_reset_task+0xd/0x10
>> =C2=A0[<c103a9ea>] ? worker_thread+0x14a/0x230
>> =C2=A0[<c103a989>] ? worker_thread+0xe9/0x230
>> =C2=A0[<c103e160>] ? autoremove_wake_function+0x0/0x40
>> =C2=A0[<c103a8a0>] ? worker_thread+0x0/0x230
>> =C2=A0[<c103de6c>] ? kthread+0x6c/0x80
>> =C2=A0[<c103de00>] ? kthread+0x0/0x80
>> =C2=A0[<c100303a>] ? kernel_thread_helper+0x6/0x1c
>> Code: 00 00 00 8d bc 27 00 00 00 00 55 b8 e0 1f 07 c1 89 e5 e8 83 93
>> fc ff c9 c3 90 55 89 e5 83 ec 10 89 5d f4 89 75 f8 89 c3 89 7d fc <6=
6>
>> f7 00 00 c0 0f 85 e4 00 00 00 8b 40 04 85 c0 0f 84 e3 00 00
>> EIP: [<c1071c51>] put_page+0x11/0x120 SS:ESP 0068:f7065e98
>> CR2: 000000002e8ca4f3
>> ---[ end trace 828c510cca9472e0 ]---
>
> Do I think correctly that this is a regression? =C2=A0If so, what's t=
he last working
> kernel?
>
Yes, it is.
It did not happen until -rc5.
2.6.33-rc4
2.6.33-rc4-00189-g6ccf80e
2.6.33-rc4-00204-g7dc9c48
2.6.33-rc4-00399-g24bc734
2.6.33-rc4-00519-g836f48c
worked fine.
Diffstat between 836f48c..v2.6.33-rc5 does not look relevant to me, as
well as 24bc734..v2.6.33-rc5.
It means the bug is not easy reproducible, I just do usual tasks, but
it has happened again:

WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1c5/0x1d0()
Hardware name:
NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
<..>
BUG kmalloc-2048: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xf4998022-0xf4998607. First byte 0x0 instead of 0x6b
INFO: Allocated in __netdev_alloc_skb+0x1e/0x40 age=3D372 cpu=3D0 pid=3D=
1724
INFO: Freed in skb_release_data+0x68/0xa0 age=3D292 cpu=3D0 pid=3D5
INFO: Slab 0xc2283300 objects=3D15 used=3D0 fp=3D0xf499b950 flags=3D0x4=
0004082
INFO: Object 0xf4998000 @offset=3D0 fp=3D0xf499d1e0

  Object 0xf4998000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
  Object 0xf4998010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
  Object 0xf4998020:  6b 6b 00 07 e9 09 d4 79 01 14 2b 09 0b 28 08 00
kk..=D0=98.=D1=82y..+..(..
  Object 0xf4998030:  45 20 05 d4 7d 09 40 00 75 06 3c e5 d5 b6 b0 b4
E..=D1=82}.@.u.<=D0=95=D1=83=E2=95=A4=E2=95=9F=E2=95=A2
  Object 0xf4998040:  c1 a8 01 02 23 28 af a3 57 1f 82 b2 c7 a5 14 d5
=D0=B0=E2=95=97..#(=E2=95=9E=D1=91W..=E2=95=A1=D0=B3=E2=95=94.=D1=83
<..>
  Object 0xf49987d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
  Object 0xf49987e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
  Object 0xf49987f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
kkkkkkkkkkkkkkk=E2=95=94
 Redzone 0xf4998800:  bb bb bb bb                                     =E2=
=95=A9=E2=95=A9=E2=95=A9=E2=95=A9
 Padding 0xf4998828:  5a 5a 5a 5a 5a 5a 5a 5a                         Z=
ZZZZZZZ
Pid: 1719, comm: rtorrent Tainted: G        W  2.6.33-rc5 #1
Call Trace:
 [<c108d1af>] print_trailer+0xcf/0x120
 [<c108d844>] check_bytes_and_report+0xc4/0xf0
 [<c108da1f>] check_object+0x1af/0x200
 [<c108db4a>] __free_slab+0xda/0x100
 [<c108db8c>] discard_slab+0x1c/0x30
 [<c108f552>] __slab_free+0xd2/0x280
 [<c11d7156>] ? copy_to_user+0x36/0x130
 [<c108f9df>] kfree+0xdf/0x110
 [<c12d30d8>] ? skb_release_data+0x68/0xa0
 [<c12d30d8>] ? skb_release_data+0x68/0xa0
 [<c12d30d8>] skb_release_data+0x68/0xa0
 [<c12d2e32>] __kfree_skb+0x12/0x90
 [<c13006a0>] tcp_recvmsg+0x6c0/0x8d0
 [<c102f691>] ? local_bh_enable_ip+0x61/0xc0
 [<c1350b75>] ? _raw_spin_unlock_bh+0x25/0x30
 [<c10435e5>] ? T.324+0x15/0x1b0
 [<c12cdc73>] sock_common_recvmsg+0x43/0x60
 [<c12cbc87>] sock_recvmsg+0xb7/0xf0
 [<c10435e5>] ? T.324+0x15/0x1b0
 [<c12cc589>] sys_recvfrom+0x79/0xe0
 [<c104d66b>] ? trace_hardirqs_off+0xb/0x10
 [<c104398e>] ? cpu_clock+0x4e/0x60
 [<c104d6a7>] ? lock_release_holdtime+0x37/0x1b0
 [<c1052121>] ? lock_release_non_nested+0x301/0x340
 [<c104d6a7>] ? lock_release_holdtime+0x37/0x1b0
 [<c107bd0a>] ? might_fault+0x4a/0xa0
 [<c12cc626>] sys_recv+0x36/0x40
 [<c12cd74c>] sys_socketcall+0x1ac/0x270
 [<c11d68f4>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c1002b10>] sysenter_do_call+0x12/0x36
=46IX kmalloc-2048: Restoring 0xf4998022-0xf4998607=3D0x6b
