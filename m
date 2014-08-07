From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [setsockopt] WARNING: CPU: 0 PID: 1444 at
 kernel/sched/core.c:7088 __might_sleep+0x51/0x16f()
Date: Thu, 7 Aug 2014 19:29:01 +0200
Message-ID: <20140807172901.GH3588@twins.programming.kicks-ass.net>
References: <20140805214624.GA9973@localhost>
 <20140807151741.GP19379@twins.programming.kicks-ass.net>
 <20140807125948.2b7f1472@thirdoffive.cmf.nrl.navy.mil>
 <20140807172514.GY9918@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Ca0e2zgpnh8/XhnM"
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
	linux-atm-general@lists.sourceforge.net
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140807172514.GY9918@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Ca0e2zgpnh8/XhnM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 07, 2014 at 07:25:14PM +0200, Peter Zijlstra wrote:
> > This isn't the only place that we queue a message for the signalling
> > daemon after a prepare_to_wait() uninterruptibly so this patch would
> > be incomplete as is.
>=20
> I'm not sure I follow, this is the only place you do so while then going
> to sleep. All other sites don't sleep while they're enqueued on the
> waitqueue.

Argh, my brain is fried, you're quite right.  I'll go have another stab
at it tomorrow or so.

--Ca0e2zgpnh8/XhnM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT47ddAAoJEHZH4aRLwOS6IJYP/AgnaGHDuGXI2z1rZGgIWO0e
pIDb2KDWni3pMhFMX5cqHGUR9GwTSJarQa0TUrzHvxIxgOznqij+N39uFDU+5VLV
5rr1CRzyOCCHRAP4hr8H0T6LkTResh2gbjE4EOEvZvlfFfYwjGwxNZmghzrMVcvG
vJYRtGWU1PM4Ge3WUIFIgEEtLTlkrFowBxclsiBG5fhBMGjzUICaWs8ot+Xpni98
s6EqE1VNnFPjJ4vvj6CiHlX/40b3bTB04IoxMEFAf3/BcYS41c1EQ3q0eKgr86+O
hI3InH7/VWK/A9A/Q99In55nLQr/ZCVVCtFOL0QJA/2QOtNgacZKuPZyg84OnHHN
ZHGPA2YkQhL0xL3oAgKqka2quFuA0FA18VQjkvUpTWltEu/BMLp0S/pns/GDenBi
YkIRrJuK+bDG0KD97XNGPeRXo903BxIcuBESslp+KbC6/70WdvbIcU4q/mJvuHfV
xW2ujDYyVf+PROsTpf3SFtWMbfzAClMrh6X2wx69VigNfQQwl2NFXpP36IzXHtfr
7ihxVFwxhBNvkRszqkYlBg2jiluXIcHbTCnrrUn6gkP2o2qn1pmZ+WaRZU7sUW06
EY29KFtGjvWrZCQfpp2TriAO20bpsw8m9lHe7TWYaF9194A7VHsivuufsXeKjflz
VN5tug3v9HQCYvhaxh9O
=Xt9h
-----END PGP SIGNATURE-----

--Ca0e2zgpnh8/XhnM--
