From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-04-28 - RCU whinges
Date: Sun, 02 May 2010 13:46:34 -0400
Message-ID: <5702.1272822394@localhost>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1272822394_4025P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 28 Apr 2010 16:53:32 PDT."
             <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1272822394_4025P
Content-Type: text/plain; charset=us-ascii

On Wed, 28 Apr 2010 16:53:32 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-04-28-16-53 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

I thought we swatted all these, hit another one...

[    9.131490] ctnetlink v0.93: registering with nfnetlink.
[    9.131535]
[    9.131535] ===================================================
[    9.131704] [ INFO: suspicious rcu_dereference_check() usage. ]
[    9.131794] ---------------------------------------------------
[    9.131883] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_dereference_check() without protection!
[    9.131977]
[    9.131977] other info that might help us debug this:
[    9.131978]
[    9.132218]
[    9.132219] rcu_scheduler_active = 1, debug_locks = 0
[    9.132434] 1 lock held by swapper/1:
[    9.132519]  #0:  (nf_ct_ecache_mutex){+.+...}, at: [<ffffffff8148922d>] nf_conntrack_register_notifier+0x1a/0x75
[    9.132938]
[    9.132939] stack backtrace:
[    9.133129] Pid: 1, comm: swapper Tainted: G        W   2.6.34-rc5-mmotm0428 #1
[    9.133220] Call Trace:
[    9.133319]  [<ffffffff81064832>] lockdep_rcu_dereference+0xaa/0xb2
[    9.133410]  [<ffffffff81489250>] nf_conntrack_register_notifier+0x3d/0x75
[    9.133521]  [<ffffffff81b5a157>] ctnetlink_init+0x71/0xd5
[    9.133627]  [<ffffffff81b5a0e6>] ? ctnetlink_init+0x0/0xd5
[    9.133735]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
[    9.133843]  [<ffffffff81b2e68a>] kernel_init+0x144/0x1ce
[    9.133949]  [<ffffffff81003414>] kernel_thread_helper+0x4/0x10
[    9.134060]  [<ffffffff81598a40>] ? restore_args+0x0/0x30
[    9.134196]  [<ffffffff81b2e546>] ? kernel_init+0x0/0x1ce
[    9.134328]  [<ffffffff81003410>] ? kernel_thread_helper+0x0/0x10
[    9.134530] ip_tables: (C) 2000-2006 Netfilter Core Team
[    9.134655] TCP bic registered


--==_Exmh_1272822394_4025P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL3bp6cC3lWbTT17ARAlQ9AKCPdEUkjgTxgN/FDhI2IsgMQc4SQQCghz57
bPOuH/bz2IQsitympyBwbWs=
=yp5X
-----END PGP SIGNATURE-----

--==_Exmh_1272822394_4025P--
