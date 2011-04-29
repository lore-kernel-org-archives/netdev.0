From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Destroying alive neighbour
Date: Fri, 29 Apr 2011 22:44:06 +0300
Message-ID: <20110429194406.GA4244@swordfish>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

.39-rc5-git2

Not sure whether I can reproduce this easily:

[  845.225899] Destroying alive neighbour ffff88015736b400
[  845.225910] Pid: 0, comm: kworker/0:1 Not tainted 2.6.39-rc5-dbg-git2-00495-g48c9216-dirty #543
[  845.225917] Call Trace:
[  845.225922]  <IRQ>  [<ffffffff813dee2f>] neigh_destroy+0x3c/0x115
[  845.225950]  [<ffffffff81400326>] ipv4_dst_check+0xae/0x158
[  845.225963]  [<ffffffff813c6f67>] __sk_dst_check+0xa5/0xd4
[  845.225975]  [<ffffffff8142e772>] inet_sk_rebuild_header+0x15/0x2b7
[  845.225989]  [<ffffffff8141c762>] ? tcp_write_timer+0x19/0x1a4
[  845.225999]  [<ffffffff8141ac3b>] tcp_retransmit_skb+0x8f/0x522
[  845.226010]  [<ffffffff81241579>] ? do_raw_spin_lock+0x6b/0x122
[  845.226020]  [<ffffffff8141c598>] tcp_retransmit_timer+0x4d5/0x686
[  845.226030]  [<ffffffff8141c7e7>] tcp_write_timer+0x9e/0x1a4
[  845.226043]  [<ffffffff8104c1f6>] run_timer_softirq+0x319/0x4f5
[  845.226053]  [<ffffffff8104c0c4>] ? run_timer_softirq+0x1e7/0x4f5
[  845.226065]  [<ffffffff8105fcf2>] ? __run_hrtimer+0x2ac/0x357
[  845.226076]  [<ffffffff8141c749>] ? tcp_retransmit_timer+0x686/0x686
[  845.226091]  [<ffffffff81044e73>] __do_softirq+0x170/0x301
[  845.226104]  [<ffffffff8106a257>] ? tick_dev_program_event+0x37/0xf6
[  845.226115]  [<ffffffff8106a330>] ? tick_program_event+0x1a/0x1c
[  845.226127]  [<ffffffff814791dc>] call_softirq+0x1c/0x30
[  845.226140]  [<ffffffff810031d7>] do_softirq+0x46/0x9f
[  845.226151]  [<ffffffff8104525a>] irq_exit+0x4e/0xa0
[  845.226166]  [<ffffffff8101954c>] smp_apic_timer_interrupt+0x87/0x95
[  845.226212]  [<ffffffff81478d13>] apic_timer_interrupt+0x13/0x20
[  845.226216]  <EOI>  [<ffffffff8126d3b7>] ? intel_idle+0xe0/0x105
[  845.226232]  [<ffffffff8126d3b0>] ? intel_idle+0xd9/0x105
[  845.226242]  [<ffffffff813b93d4>] cpuidle_idle_call+0x157/0x288
[  845.226250]  [<ffffffff810007aa>] cpu_idle+0xa2/0xf3
[  845.226259]  [<ffffffff8146244b>] start_secondary+0x1ee/0x1f7


	Sergey

--ReaqsoxgOBHFXBhH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iJwEAQECAAYFAk27FQYACgkQfKHnntdSXjTm2QP+MeBVgjIx/YTfMMQokqHOEDcW
O97fP5OBHADSxKF3DUhm/A8PlLuUoBsERtTtm3pFpBhr0BZ9EnlTWJJxkcD/JnU2
YDlj2FLaD7U8SDvPAHCMSvzR/zIfWNUYYG5Ggnqs3g4ixOAF5YfjYKECqOltGYB2
9bnNAJTJIM/r/4WpYC0=
=Gm3t
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--
