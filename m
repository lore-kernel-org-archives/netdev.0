From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me comment in
 the function,gb_acquire_swfw_sync_i210
Date: Mon, 09 Feb 2015 01:35:32 -0800
Message-ID: <1423474532.27854.17.camel@jtkirshe-mobl>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
	 <1423444889.2589.165.camel@jtkirshe-mobl> <54D85EFA.3020501@gmail.com>
	 <1423470722.27854.11.camel@jtkirshe-mobl> <87egpzqvpc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aT+KtdJz4fWSrewDki8r"
Cc: Andrej Manduch <amanduch@gmail.com>,
	Nicholas Krause <xerofoify@gmail.com>,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87egpzqvpc.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-aT+KtdJz4fWSrewDki8r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-02-09 at 10:29 +0100, Bj=C3=B8rn Mork wrote:
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>=20
> > If you want to see Nick's patch, feel free to view his patch on
> > my queue tree:
> > https://git.kernel.org/cgit/linux/kernel/git/jkirsher/queue.git/
>=20
> which said:
>   - s32 i =3D 0, timeout =3D 200; /* FIXME: find real value to use here *=
/
>   + s32 i =3D 0, timeout =3D 200;
>=20
>=20
> Comments like the one deleted by that patch do have some value in my
> opinion: They document that the constant is chosen arbitrarily and is
> not taken from some datasheet.
>=20
> Not a big deal, but leaving such comments, even if the value never
> ever
> changes, could save someone from trying to figure out where the heck
> you
> got that constant.  And there's noone actually misinterpreting this
> comment as "something needs to be fixed here", is there? So the cost
> of
> leaving the comment is exactly zero.
>=20
> Just my .02 =E2=82=AC.  I'm not going to tell you how to maintain your dr=
iver,
> of course.  At least I try not to :-)

I see your point and I will have Carolyn take look to see if the comment
should rather be changed to see if we can describe why the value and
remove the FIXME at the same time.

--=-aT+KtdJz4fWSrewDki8r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2H9lAAoJEOVv75VaS+3Off0P/2DooUSyKquH7ar5HtwKoquH
VMuIj3KqT3vfs2cKWOh52hrG2MXCs197i/KHj2+wvYCIWSERfRekfdM7ATdWQMcT
netGX7Y/20ke/y3rihQdqqfVJQ/3vdvG4vabH3olIFCkZZQ1QA0oiWj+RSs0Rjq8
un4+MYwNbNrMSy/7WTDogwi9F8yftG8gv1MnyRNEPJWicKFPpFmvDeiBCtqlK3rU
j+sPE/Wd8OP+KcIbSe3lwB405o2s1wQm1vW2tvoqcbu9d1DQ0wkHE0qP2D12EJw3
9ouvXTNKTL/CxaCfGtxhByn+T4DB1T6UAc+VtpFfZoi3WZze33nPWI7fLaKvfaz0
8vbHyqi+solfw/6FMWi3BiFq54cX7nprHgbghHE/nVHo946uj0vT1RmQQL4KY/Z4
7YCgaF+gYn50L9XSA7nHZ+CNffjJQyi0qK9cRQ3Cph6BScVlqDc3cwsZAFrbxucr
JaHtBbUmrbaI6s0l7B87hsd5qf1BNs/62kp9vgz2mVr5Kia/kQkuJxQcLTFUc6Ic
J2lMo8A78LPN9V4h+X0meyoo3TDfEfnaQVIR0TFBxc9o7pvV+syUokCa7zg4o/aF
8xU+tPsMDnMJ79+D4OTIiN39QlKY4154597TiiVfqX2dVsnw9I3FdXGMSqokT0vo
Uv9tuSm2orL4zoZmcO7m
=PvCV
-----END PGP SIGNATURE-----

--=-aT+KtdJz4fWSrewDki8r--
