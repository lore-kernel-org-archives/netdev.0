From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 16:53:24 +0200
Message-ID: <20130219145324.GE4390@arwen.pp.htv.fi>
References: <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
 <20130219131500.GW23197@arwen.pp.htv.fi>
 <20130219132853.GG26623@pd.tnic>
 <20130219133809.GA4390@arwen.pp.htv.fi>
 <20130219135056.GH26623@pd.tnic>
 <20130219113521.510db290@redhat.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3XA6nns4nE4KvaS/"
Cc: Borislav Petkov <bp@alien8.de>, Felipe Balbi <balbi@ti.com>,
	Greg KH <gregkh@linuxfoundation.org>,
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
In-Reply-To: <20130219113521.510db290@redhat.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--3XA6nns4nE4KvaS/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 19, 2013 at 11:35:21AM -0300, Mauro Carvalho Chehab wrote:
> Em Tue, 19 Feb 2013 14:50:56 +0100
> Borislav Petkov <bp@alien8.de> escreveu:
>=20
> > On Tue, Feb 19, 2013 at 03:38:09PM +0200, Felipe Balbi wrote:
> > > because changing the permission will cause the same issue:
> >=20
> > Actually, I take that back. Mauro's patch will already create the file
> > anyway:
> >=20
> > 	if (mci->set_sdram_scrub_rate || mci->get_sdram_scrub_rate)
> >=20
> > Adjusting the permissions is simply the last missing piece to this patch
> > to make the interface to userspace 100% coherent.
>=20
> That's covers everything but Hannes arguments. I don't think that
> adding just one more device_create_file() on a driver that creates
> dozens (or hundreds) of sys nodes, depending on the number of DIMMS
> on the system would make it any worse.
>=20
> Regards,
> Mauro
>=20
> [PATCH EDAC] edac: only create sdram_scrub_rate where supported
>=20
> Currently, sdram_scrub_rate sysfs node is created even if the device
> doesn't support get/set the scub rate. Change the logic to only
> create this device node when the operation is supported.
>=20
> Reported-by: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Mauro Carvalho Chehab <mchehab@redhat.com>

looks alright to me:

Reviewed-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--3XA6nns4nE4KvaS/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI5HkAAoJEIaOsuA1yqREa5kP/0Zv2X9u7znMsYofXocxvmX3
BCrtM3ZDIn4ygfMJfbA+eVLTxDXanThEiM15PwXj9xiJRoWfQt2TG+MtmaYNS8QA
SmALUtFvg6Azm337Nn23/E0QEjxh0XXc9hz4O5pOyKQWRTRl+GIh52CWEPHkpGqA
3I4NANCKm3j2vrG2Paia/+PJ0sX7sGkmx88qb2WJESXCMOeUe8Lvyim6957mkOaO
40JPJriYMByEEpMs7HnALz7vIUn/vh7bZ2VhE7PHgs5QyunKmoEueR0fXpCQUHaO
FtiZNmEPdlkEw1ZruEihbma1IvjyWoTqmEUhHhwnWddxpVc87y0EJ8Hw6hHDXOW5
c9COqI3GtSt3jtJa/wGrt4N8P9Qa6SlmW4GjFk1k5qXP/mC63/hL1GmtAaInj+EL
VhUOk04yt4lXGnCkANNuJkAVgUqMXhSUGU2pJUq3TTe/wi1yMMPQ3KZ5g2pCE3T8
swyvZ8r67mac7oHBoCGGKTlX18mZALw/hbkGjtxY/9i3G1MmKulwTtA93OtHxd7f
yjX92juXSP5gksj+xGPmaITItLTzX5YiCFNAcw2H6et8z6P/I8W0qpyWMnRf5rqx
XXUqJlj+prHo9Nyk7Rr+LCB7m1wMLdZMsNKEwiO0ndtYWXtPZkC9s0ne4oGVxYPY
GDm7+tNoOyst5JvLm+tj
=uOh6
-----END PGP SIGNATURE-----

--3XA6nns4nE4KvaS/--
