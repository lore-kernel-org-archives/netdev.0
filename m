From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: r8169 INFO: inconsistent lock state
Date: Fri, 30 Apr 2010 21:20:12 +0300
Message-ID: <20100430182012.GA3329@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:52392 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759285Ab0D3STL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:19:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

Yet another one (during resume):

kernel: [ 1968.334646]=20
kernel: [ 1968.334648] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
kernel: [ 1968.334651] [ INFO: inconsistent lock state ]
kernel: [ 1968.334654] 2.6.34-rc6-dbg #105
kernel: [ 1968.334656] ---------------------------------
kernel: [ 1968.334659] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
kernel: [ 1968.334663] events/1/3854 [HC0[0]:SC0[0]:HE1:SE1] takes:
kernel: [ 1968.334666]  (&(&table->hash[i].lock)->rlock){+.?...}, at: [<c12=
92ec4>] __udp4_lib_mcast_deliver+0x3c/0x143
kernel: [ 1968.334678] {IN-SOFTIRQ-W} state was registered at:
kernel: [ 1968.334681]   [<c104fc8d>] __lock_acquire+0x2ba/0xc01
kernel: [ 1968.334688]   [<c10509df>] lock_acquire+0x5e/0x75
kernel: [ 1968.334693]   [<c12c366a>] _raw_spin_lock+0x28/0x58
kernel: [ 1968.334699]   [<c1292ec4>] __udp4_lib_mcast_deliver+0x3c/0x143
kernel: [ 1968.334704]   [<c12931a7>] __udp4_lib_rcv+0x1dc/0x3ac
kernel: [ 1968.334708]   [<c1293389>] udp_rcv+0x12/0x14
kernel: [ 1968.334713]   [<c127605f>] ip_local_deliver_finish+0xd2/0x137
kernel: [ 1968.334719]   [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
kernel: [ 1968.334724]   [<c1276220>] ip_local_deliver+0x3c/0x42
kernel: [ 1968.334728]   [<c1275f2e>] ip_rcv_finish+0x25c/0x27e
kernel: [ 1968.334733]   [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
kernel: [ 1968.334737]   [<c12763c9>] ip_rcv+0x1a3/0x1c6
kernel: [ 1968.334741]   [<c12593d7>] netif_receive_skb+0x38b/0x3ab
kernel: [ 1968.334747]   [<fd20f911>] rtl8169_rx_interrupt+0x2de/0x3eb [r81=
69]
kernel: [ 1968.334756]   [<fd211cde>] rtl8169_poll+0x28/0x15d [r8169]
kernel: [ 1968.334763]   [<c12596b3>] net_rx_action+0x93/0x181
kernel: [ 1968.334767]   [<c1032a72>] __do_softirq+0x88/0x10c
kernel: [ 1968.334773]   [<c1032b25>] do_softirq+0x2f/0x47
kernel: [ 1968.334778]   [<c1032de2>] irq_exit+0x38/0x75
kernel: [ 1968.334782]   [<c1004489>] do_IRQ+0x79/0x8d
kernel: [ 1968.334787]   [<c1002db5>] common_interrupt+0x35/0x3c
kernel: [ 1968.334791]   [<c1246f43>] cpuidle_idle_call+0x6a/0xa0
kernel: [ 1968.334799]   [<c100171b>] cpu_idle+0x89/0xbe
kernel: [ 1968.334802]   [<c12b3d49>] rest_init+0xd1/0xd6
kernel: [ 1968.334807]   [<c147e7bd>] start_kernel+0x339/0x33e
kernel: [ 1968.334813]   [<c147e0c9>] i386_start_kernel+0xc9/0xd0
kernel: [ 1968.334818] irq event stamp: 63
kernel: [ 1968.334820] hardirqs last  enabled at (63): [<c109d7ff>] kmem_ca=
che_free+0x83/0x8f
kernel: [ 1968.334828] hardirqs last disabled at (62): [<c109d7a6>] kmem_ca=
che_free+0x2a/0x8f
kernel: [ 1968.334833] softirqs last  enabled at (60): [<c126400a>] rcu_rea=
d_unlock_bh+0x1c/0x1e
kernel: [ 1968.334839] softirqs last disabled at (58): [<c1263faf>] rcu_rea=
d_lock_bh+0x8/0x26
kernel: [ 1968.334845]=20
kernel: [ 1968.334846] other info that might help us debug this:
kernel: [ 1968.334849] 5 locks held by events/1/3854:
kernel: [ 1968.334851]  #0:  (events){+.+.+.}, at: [<c103c8e9>] worker_thre=
ad+0x128/0x23c
kernel: [ 1968.334859]  #1:  ((&(&tp->task)->work)){+.+...}, at: [<c103c8e9=
>] worker_thread+0x128/0x23c
kernel: [ 1968.334865]  #2:  (rtnl_mutex){+.+.+.}, at: [<c1262b8f>] rtnl_lo=
ck+0xf/0x11
kernel: [ 1968.334871]  #3:  (rcu_read_lock){.+.+..}, at: [<c125784b>] rcu_=
read_lock+0x0/0x2b
kernel: [ 1968.334877]  #4:  (rcu_read_lock){.+.+..}, at: [<c1275c56>] rcu_=
read_lock+0x0/0x2b
kernel: [ 1968.334884]=20
kernel: [ 1968.334885] stack backtrace:
kernel: [ 1968.334888] Pid: 3854, comm: events/1 Not tainted 2.6.34-rc6-dbg=
 #105
kernel: [ 1968.334891] Call Trace:
kernel: [ 1968.334895]  [<c12c1906>] ? printk+0xf/0x11
kernel: [ 1968.334901]  [<c104e7d9>] valid_state+0x133/0x141
kernel: [ 1968.334906]  [<c104e8b6>] mark_lock+0xcf/0x1bc
kernel: [ 1968.334911]  [<c104e11f>] ? check_usage_backwards+0x0/0x72
kernel: [ 1968.334915]  [<c104fcff>] __lock_acquire+0x32c/0xc01
kernel: [ 1968.334922]  [<c129ee2d>] ? fib_table_lookup+0x81/0x8e
kernel: [ 1968.334927]  [<c100772e>] ? __cycles_2_ns+0xf/0x3e
kernel: [ 1968.334932]  [<c12671b6>] ? rcu_read_unlock+0x0/0x38
kernel: [ 1968.334937]  [<c1007a30>] ? native_sched_clock+0x49/0x4f
kernel: [ 1968.334943]  [<c10443a9>] ? sched_clock_local+0x11/0x11f
kernel: [ 1968.334948]  [<c10509df>] lock_acquire+0x5e/0x75
kernel: [ 1968.334953]  [<c1292ec4>] ? __udp4_lib_mcast_deliver+0x3c/0x143
kernel: [ 1968.334958]  [<c12c366a>] _raw_spin_lock+0x28/0x58
kernel: [ 1968.334963]  [<c1292ec4>] ? __udp4_lib_mcast_deliver+0x3c/0x143
kernel: [ 1968.334967]  [<c1292ec4>] __udp4_lib_mcast_deliver+0x3c/0x143
kernel: [ 1968.334973]  [<c104463c>] ? sched_clock_cpu+0x121/0x131
kernel: [ 1968.334978]  [<c12735b5>] ? rcu_read_unlock+0x0/0x38
kernel: [ 1968.334983]  [<c104463c>] ? sched_clock_cpu+0x121/0x131
kernel: [ 1968.334988]  [<c10505c5>] ? __lock_acquire+0xbf2/0xc01
kernel: [ 1968.334994]  [<c12735e2>] ? rcu_read_unlock+0x2d/0x38
kernel: [ 1968.334998]  [<c1274034>] ? ip_route_input+0x101/0xaf4
kernel: [ 1968.335003]  [<c12931a7>] __udp4_lib_rcv+0x1dc/0x3ac
kernel: [ 1968.335008]  [<c1293389>] udp_rcv+0x12/0x14
kernel: [ 1968.335013]  [<c127605f>] ip_local_deliver_finish+0xd2/0x137
kernel: [ 1968.335017]  [<c1275f8d>] ? ip_local_deliver_finish+0x0/0x137
kernel: [ 1968.335022]  [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
kernel: [ 1968.335026]  [<c1276220>] ip_local_deliver+0x3c/0x42
kernel: [ 1968.335031]  [<c1275f8d>] ? ip_local_deliver_finish+0x0/0x137
kernel: [ 1968.335035]  [<c1275f2e>] ip_rcv_finish+0x25c/0x27e
kernel: [ 1968.335040]  [<c1275cd2>] ? ip_rcv_finish+0x0/0x27e
kernel: [ 1968.335044]  [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
kernel: [ 1968.335048]  [<c12763c9>] ip_rcv+0x1a3/0x1c6
kernel: [ 1968.335052]  [<c1275cd2>] ? ip_rcv_finish+0x0/0x27e
kernel: [ 1968.335057]  [<c12593d7>] netif_receive_skb+0x38b/0x3ab
kernel: [ 1968.335066]  [<fd20f911>] rtl8169_rx_interrupt+0x2de/0x3eb [r816=
9]
kernel: [ 1968.335073]  [<fd20fc9b>] rtl8169_reset_task+0x33/0xe8 [r8169]
kernel: [ 1968.335077]  [<c103c92b>] worker_thread+0x16a/0x23c
kernel: [ 1968.335082]  [<c103c8e9>] ? worker_thread+0x128/0x23c
kernel: [ 1968.335088]  [<fd20fc68>] ? rtl8169_reset_task+0x0/0xe8 [r8169]
kernel: [ 1968.335095]  [<c103fa46>] ? autoremove_wake_function+0x0/0x2f
kernel: [ 1968.335099]  [<c103c7c1>] ? worker_thread+0x0/0x23c
kernel: [ 1968.335103]  [<c103f76a>] kthread+0x6a/0x6f
kernel: [ 1968.335108]  [<c103f700>] ? kthread+0x0/0x6f
kernel: [ 1968.335112]  [<c1002dc2>] kernel_thread_helper+0x6/0x10
kernel: [ 1968.335282] r8169 0000:02:00.0: eth0: link down


	Sergey

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkvbH1wACgkQfKHnntdSXjQDRgQAvWGIQgbl0h7+3jjBiG1nAYZw
73V8oJ9IcoBrweGNBIEzRZz76Rkmp4dBE/SaGbVe1o7ZHT5cRxwUdB8dnG6Jym1H
/uYYo9qu5pakwMINBM7sOzsMI1PrN6Lz77fjOf9yBoUzjkDaRUrRpLQiOvP1AKPA
nqdsZIsEFKx70Btr6kg=
=VSOr
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--
