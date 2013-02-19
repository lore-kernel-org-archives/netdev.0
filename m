From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 12:11:21 +0200
Message-ID: <20130219101121.GJ23197@arwen.pp.htv.fi>
References: <20130218174916.GA2070@kroah.com>
 <20130218184633.GC10755@arwen.pp.htv.fi>
 <20130218164638.7cb53baa@redhat.com>
 <20130218200542.GB20137@arwen.pp.htv.fi>
 <20130218184742.5a4c3c06@redhat.com>
 <20130218215434.GB16794@kroah.com>
 <20130218221306.GA21493@pd.tnic>
 <20130218222618.GA21818@kroah.com>
 <20130218224405.GB21493@pd.tnic>
 <20130219070310.2cadad7a@redhat.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PEkEgRdBLZYkpbX2"
Cc: Borislav Petkov <bp@alien8.de>,
	Greg KH <gregkh@linuxfoundation.org>, <balbi@ti.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130219070310.2cadad7a@redhat.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--PEkEgRdBLZYkpbX2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 07:03:10AM -0300, Mauro Carvalho Chehab wrote:
> > But my gut feeling says to stay concervative and not touch this code -
> > we don't know what uses it and how much we would break by "fixing" it.
> > The current situation is not that big of a deal IMVHO and I'd be willing
> > to accept the small inconcistency versus possibly breaking userspace.
>=20
> I remember I saw some discussions about it in the past at bluesmoke ML,
> saying that -ENODEV is the expected behavior when this is not supported.
>=20
> Changing from -ENODEV to "N/A" will break anything that would be relying
> on the previous behavior. So, I think that such change will for sure break
> userspace.
>=20
> If we're willing to change it, not creating the "sdram_scrub_rate" sysfs=
=20
> node is less likely to affect userspace.

yeah, I agree with this. Guess we shouldn't be creating files which
aren't supported by the underlying HW and having a read() return -ENODEV
is quite weird IMO since that's actually 'breaking' read() interface
although that's up to interpretations.

--=20
balbi

--PEkEgRdBLZYkpbX2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI0/JAAoJEIaOsuA1yqREB/4P/jd/dGVZSoGjV7FrsOEuG/O9
FyWi0VRov4gOmyTomCL28e3qlKLOyPcnmgsMaj+5OVkIu0BqSrsh76zs9a67ONka
GX/Wsq7uNo+GH2/5ECKO72QGQIbOFN4c9Lpb1NgYuZWX4dKESwLSOojxsxw4a4NZ
mlBUtIUhXuuLVQnXX7GcQ/2fs0SOodYJXTBPzxMb/lMqeP3svIJRy+tUxV93VyZp
ZiZyuYdY5qeflo8vtA5AZMOIqLrhcsG/4vLvioGxkX93p9uwG8fP+NlFlIkVyWgC
THDidjApsB21hFXnoAEid4tWD+MD5iaJ76k2CAI0aM39AxiEkmJ38FiEKKppWPEj
rf6o6VQeB55ppuPbIW1qoEj1MTYyx7kTGFmgqpur3kpbYpZJlFrulQOQblsGge8v
MNNq0WInhW4RIaxz2kpjcnrou2q4DC7Aq4HkL0RdfEPC/d2uHomxX+2dzxSRAVfY
A7o4t8X3vxydRyujwSQIqcdFTnL/C5I2+5ZdMA2fC0yhVbY/d/KqPhKrs7qNtABX
x1iBGTRYALtF23dbxKQDg2HSv6lOH2+9Okkmh36ZDqePd6ftKZeX57u2YmojQXXv
24d5NAXKD3iAz2fgNTszF6kkw62PpPhjXgcUZ3jW+DXFEECHw1jIAEDeFzvJIDn8
DghQDgawKtAmpImLlpur
=ZlSk
-----END PGP SIGNATURE-----

--PEkEgRdBLZYkpbX2--
