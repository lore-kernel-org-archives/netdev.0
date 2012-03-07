From: Valdis.Kletnieks@vt.edu
Subject: 3.3.0-rc6-next20120305 net/ipv4/tcp_ipv4.c:930 suspicious rcu_dereference_check() usage!
Date: Wed, 07 Mar 2012 08:25:26 -0500
Message-ID: <30475.1331126726@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1331126726_3519P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1331126726_3519P
Content-Type: text/plain; charset=us-ascii

Seen in my dmesg.  Dell Latitude E6500.

[  164.842511]
[  164.842522] ===============================
[  164.842528] [ INFO: suspicious RCU usage. ]
[  164.842538] 3.3.0-rc6-next-20120305 #1 Tainted: G           O
[  164.842544] -------------------------------
[  164.842552] net/ipv4/tcp_ipv4.c:930 suspicious rcu_dereference_check() usage!
[  164.842559]
[  164.842560] other info that might help us debug this:
[  164.842563]
[  164.842570]
[  164.842571] rcu_scheduler_active = 1, debug_locks = 1
[  164.842579] 2 locks held by ksoftirqd/1/10:
[  164.842586]  #0:  (&icsk->icsk_retransmit_timer){+.-...}, at: [<ffffffff81039086>] run_timer_softirq+0x17f/0x3e7
[  164.842620]  #1:  (slock-AF_INET){+.-...}, at: [<ffffffff814b75b3>] tcp_write_timer+0x1a/0x17b
[  164.842649]
[  164.842651] stack backtrace:
[  164.842660] Pid: 10, comm: ksoftirqd/1 Tainted: G           O 3.3.0-rc6-next-20120305 #1
[  164.842668] Call Trace:
[  164.842685]  [<ffffffff8106e6a2>] lockdep_rcu_suspicious+0xec/0xf5
[  164.842698]  [<ffffffff814b7f40>] tcp_md5_do_lookup+0x60/0xbe
[  164.842710]  [<ffffffff814b7fc0>] tcp_v4_md5_lookup+0xe/0x10
[  164.842725]  [<ffffffff814b2eb5>] tcp_established_options+0x32/0x110
[  164.842739]  [<ffffffff814b42d7>] tcp_current_mss+0x50/0x6f
[  164.842753]  [<ffffffff814b5c50>] tcp_retransmit_skb+0xa9/0x510
[  164.842766]  [<ffffffff814ab727>] ? tcp_set_ca_state+0x23/0x2f
[  164.842779]  [<ffffffff814b73ee>] tcp_retransmit_timer+0x376/0x521
[  164.842791]  [<ffffffff814b7638>] tcp_write_timer+0x9f/0x17b
[  164.842804]  [<ffffffff8103915e>] run_timer_softirq+0x257/0x3e7
[  164.842816]  [<ffffffff81039086>] ? run_timer_softirq+0x17f/0x3e7
[  164.842828]  [<ffffffff814b7599>] ? tcp_retransmit_timer+0x521/0x521
[  164.842843]  [<ffffffff81032207>] __do_softirq+0x10a/0x25f
[  164.842857]  [<ffffffff81032411>] run_ksoftirqd+0xb5/0x200
[  164.842869]  [<ffffffff8103235c>] ? __do_softirq+0x25f/0x25f
[  164.842884]  [<ffffffff810499bd>] kthread+0x86/0x8e
[  164.842900]  [<ffffffff815e2434>] kernel_thread_helper+0x4/0x10
[  164.842914]  [<ffffffff815db41d>] ? retint_restore_args+0xe/0xe
[  164.842928]  [<ffffffff81049937>] ? flush_kthread_worker+0xcf/0xcf
[  164.842941]  [<ffffffff815e2430>] ? gs_change+0xb/0xb


--==_Exmh_1331126726_3519P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBT1dhxgdmEQWDXROgAQK2UxAAqUt22B1GOx7sxbc70lHTk7qkb4EseU3K
C44uK+sYu4ijy3uEx7CUgXcWXZeuG39ULaKTAYjYETw2DmKXC1MeA6UxgXXHxqm1
opiZ9rhoN7cdXSx4EOsBO3EQesoR/xNdafIapZRoJTxUQQDwekCtVFUM4iPuM8XN
UVL0jLZ27VFEO6SaOLy/SUl3TnRTIbV+BcG5y1FQAWQqXG2ygbmXsoKBTzQuqFna
s/EGfZyYdow49HM40EeBpFNsKa46fCc+c1R/fofKehpl0hofpa7n7LtN+GHZRkIT
SdsC8M1871svl2vrW/bMeSU8+hYMWcjU8q9pjv6AybJQJfcZvI1kBVmeIUSGpZNy
Sq384V1DwdF7Tgj8vqnKDqzw2Hzaay7jl4T8qGWvV4l613gKELZcgXzXW/r63Wdr
rfKRn2bCIKP/urwPFJwUBjjLMjst6IPHs06xj1FnFs+ZkJ4gBcPFvyDn+W7JXdw5
I5jgQLF+Mib4Esezh4AWUtCTej4NegZJicGwpL4nVKtnntfQFJvzp/zy6HkTIR5p
VrmdwndXq9Hj8Lkyu+aDDRLWw4+g5RnpwPdDU0G6SxF1SOQES4Il1xC7r33Jec52
s6QZ+f8RtRKKNV+vWvErhCau+GBHJCPC5i7efJHLpXDwxsphKE32luAa1wOqnDWQ
TBj0KbRj8ZM=
=Yj46
-----END PGP SIGNATURE-----

--==_Exmh_1331126726_3519P--
