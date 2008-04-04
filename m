From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173
	tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 4 Apr 2008 01:22:01 -0700
Message-ID: <20080404082201.GC20121@curie-int.orbis-terrarum.net>
References: <20080402224137.GB25768@curie-int.orbis-terrarum.net> <20080403211913.3a0c1d00.akpm@linux-foundation.org> <20080403212038.ec0a4244.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2JFBq9zoW8cOFH7v"
Cc: "Robin H. Johnson" <robbat2@gentoo.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758903AbYDDIW4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080403212038.ec0a4244.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2JFBq9zoW8cOFH7v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 03, 2008 at 09:20:38PM -0700, Andrew Morton wrote:
> On Thu, 3 Apr 2008 21:19:13 -0700 Andrew Morton <akpm@linux-foundation.or=
g> wrote:
>=20
> >=20
> > (cc netdev)
> >=20
> > (and Rafael - I assume 2.6.24 didn't do this..)
>=20
> urgh.
>=20
> > On Wed, 2 Apr 2008 15:41:37 -0700 "Robin H. Johnson" <robbat2@gentoo.or=
g> wrote:
> >=20
> > > (Please CC, not on LKML).
> > >=20
> > > One of the nodes in my web-serving cluster (isohunt.com) started show=
ing this:
> > >=20
> > > ------------[ cut here ]------------
> > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
> > > Modules linked in: lm85 hwmon_vid nfs lockd nfs_acl sunrpc bonding re=
iserfs k8temp hwmon i2c_nforce2 i2c_core sg
> > > Pid: 32500, comm: php-cgi Not tainted 2.6.25-rc4-git2 #7
> I misread that as -rc8.
> We fixed a lot of stuff since -rc4.  Please retest current mainline?

Hopefully this is new enough. -git3 was released right while I was writing =
this
email after testing, and I don't see anything in there that seems related.

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x2bb/0x2c0()
Modules linked in: lm85 hwmon_vid nfs lockd nfs_acl sunrpc bonding reiserfs=
 i2c_nforce2 k8temp hwmon i2c_core sg
Pid: 0, comm: swapper Not tainted 2.6.25-rc8-git2 #1

Call Trace:
 <IRQ>  [<ffffffff8023413f>] warn_on_slowpath+0x5f/0x80
 [<ffffffff803ecefb>] ? e1000_alloc_rx_buffers+0xdb/0x3a0
 [<ffffffff803edcc2>] ? e1000_clean_rx_irq+0x312/0x5a0
 [<ffffffff805a44db>] tcp_enter_frto+0x2bb/0x2c0
 [<ffffffff805aa661>] tcp_write_timer+0x3a1/0x790
 [<ffffffff8024c3e5>] ? hrtimer_run_pending+0x35/0xc0
 [<ffffffff805aa2c0>] ? tcp_write_timer+0x0/0x790
 [<ffffffff8023dd5f>] run_timer_softirq+0x18f/0x1f0
 [<ffffffff80239e74>] __do_softirq+0x74/0xf0
 [<ffffffff8020ee9a>] ? profile_pc+0x3a/0x70
 [<ffffffff8020c7cc>] call_softirq+0x1c/0x30
 [<ffffffff8020ecbd>] do_softirq+0x3d/0x80
 [<ffffffff80239df5>] irq_exit+0x45/0x50
 [<ffffffff8021c62e>] smp_apic_timer_interrupt+0x7e/0xc0
 [<ffffffff8020a480>] ? default_idle+0x0/0x70
 [<ffffffff8020c276>] apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff8020a4b9>] ? default_idle+0x39/0x70
 [<ffffffff8020a4b4>] ? default_idle+0x34/0x70
 [<ffffffff8020a480>] ? default_idle+0x0/0x70
 [<ffffffff8020a565>] ? cpu_idle+0x75/0xa0
 [<ffffffff8061deca>] ? rest_init+0x5a/0x60

---[ end trace 52f4c6f608900cab ]---
--=20
Robin Hugh Johnson
Gentoo Linux Developer & Infra Guy
E-Mail     : robbat2@gentoo.org
GnuPG FP   : 11AC BA4F 4778 E3F6 E4ED  F38E B27B 944E 3488 4E85

--2JFBq9zoW8cOFH7v
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)
Comment: Robbat2 @ Orbis-Terrarum Networks - The text below is a digital signature. If it doesn't make any sense to you, ignore it.

iEYEARECAAYFAkf15SkACgkQPpIsIjIzwixbUgCgq8esbbnFRervYguL/M8Z0lDk
tiUAn2nWnjsYwfNagkiX5iw4F1+qa8fy
=zuhl
-----END PGP SIGNATURE-----

--2JFBq9zoW8cOFH7v--
