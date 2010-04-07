From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-04-05-16-09 uploaded
Date: Wed, 07 Apr 2010 14:01:49 -0400
Message-ID: <13074.1270663309@localhost>
References: <201004052336.o35NaeSE015814@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1270663309_3901P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: Your message of "Mon, 05 Apr 2010 16:09:45 PDT."
             <201004052336.o35NaeSE015814@imap1.linux-foundation.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1270663309_3901P
Content-Type: text/plain; charset=us-ascii

On Mon, 05 Apr 2010 16:09:45 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-04-05-16-09 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Seen in dmesg, 2.6.34-rc2-mmotm0323 didn't do this. Tossing it at all the
likely suspects, hopefully somebody will recognize it and save me the
bisecting. ;)

[   11.488535] ctnetlink v0.93: registering with nfnetlink.
[   11.488579] 
[   11.488579] ===================================================
[   11.489529] [ INFO: suspicious rcu_dereference_check() usage. ]
[   11.489988] ---------------------------------------------------
[   11.490494] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_dereference_check() without protection!
[   11.491024] 
[   11.491024] other info that might help us debug this:
[   11.491025] 
[   11.492834] 
[   11.492835] rcu_scheduler_active = 1, debug_locks = 0
[   11.494124] 1 lock held by swapper/1:
[   11.494776]  #0:  (nf_ct_ecache_mutex){+.+...}, at: [<ffffffff8148c606>] nf_conntrack_register_notifier+0x1a/0x76
[   11.495505] 
[   11.495506] stack backtrace:
[   11.496927] Pid: 1, comm: swapper Not tainted 2.6.34-rc3-mmotm0405 #1
[   11.497668] Call Trace:
[   11.498419]  [<ffffffff810638c5>] lockdep_rcu_dereference+0xaa/0xb2
[   11.499185]  [<ffffffff8148c629>] nf_conntrack_register_notifier+0x3d/0x76
[   11.499967]  [<ffffffff81b5dd7b>] ctnetlink_init+0x71/0xd5
[   11.500775]  [<ffffffff81b5dd0a>] ? ctnetlink_init+0x0/0xd5
[   11.501579]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
[   11.502396]  [<ffffffff81b3268a>] kernel_init+0x144/0x1ce
[   11.503218]  [<ffffffff81003514>] kernel_thread_helper+0x4/0x10
[   11.504047]  [<ffffffff8159cc00>] ? restore_args+0x0/0x30
[   11.504882]  [<ffffffff81b32546>] ? kernel_init+0x0/0x1ce
[   11.505715]  [<ffffffff81003510>] ? kernel_thread_helper+0x0/0x10
[   11.506636] ip_tables: (C) 2000-2006 Netfilter Core Team
[   11.507372] TCP bic registered


--==_Exmh_1270663309_3901P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLvMiNcC3lWbTT17ARAn4kAJ9/0RdAq3s0dOuASnNdracwxYzltACdFoxk
awnQo03tntDhlr0YT0ahASU=
=dQIQ
-----END PGP SIGNATURE-----

--==_Exmh_1270663309_3901P--

