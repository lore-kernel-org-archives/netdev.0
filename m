From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: constify i40e_client_ops structure
Date: Fri, 13 May 2016 12:40:05 -0700
Message-ID: <1463168405.2612.23.camel@intel.com>
References: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>
	 <0c2df9ca-64bd-ac73-9071-f4d619887df8@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vV0PYM8H2g365e1FqTYt"
Cc: kernel-janitors@vger.kernel.org, linux-rdma@vger.kernel.org,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
	Shiraz Saleem <shiraz.saleem@intel.com>,
	Mustafa Ismail <mustafa.ismail@intel.com>,
	Chien Tin Tung <chien.tin.tung@intel.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0c2df9ca-64bd-ac73-9071-f4d619887df8@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vV0PYM8H2g365e1FqTYt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-05-13 at 12:50 -0400, Doug Ledford wrote:
> On 05/01/2016 08:07 AM, Julia Lawall wrote:
> > The i40e_client_ops structure is never modified, so declare it as
> const.
> >=C2=A0
> > Done with the help of Coccinelle.
> >=C2=A0
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> Thanks, applied.

I already have this patch queued up to push through David Miller's net-next=
=20
tree.

Julia- please do not shotgun blast several maintainers and several lists,
it causes confusion on who is *REALLY* going to accept and apply the patch.
Please use scripts/get_maintainer.pl to get the correct mailing lists and
maintainers to add to the To: and CC: lines.
--=-vV0PYM8H2g365e1FqTYt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXNi2VAAoJEOVv75VaS+3O7IkP/09XaicK8c6ye5Qj1w9wtN9s
fDeDOoUGjDQgUglacfackaoprYHduiPjeK/SRzmIa9BYBqhrCt6LKGOpsaZ+9Eot
HRg6pppEDTdlxuphSwaSzuvZ36Po3weTlvHwvnYvB+uIs0QUtq0LwKTms0d9WsTM
GgaCIdvHXi8In1WwCiQY1Pw7Q3G/T4LyqZZJLsS5j+sCtxzinoRqIpSyhCMXmUrK
tU8lYDQL8tITev3lFN8kIC2EW/m5emJOEBBoK3Ei1bHywnERUukfOc0n8bowxbKj
9b2vSWLyEOUY9CL0leeMimjAbnojmlblLh5GYJZX08KDqddIiI2sBrLqiGHQ6G0V
L3vFaxJ//gtwmwjA1YhYTW3OiHTpWV/DN3L7JtFuTh+6WqaKA6KST1d77KLieLax
olHufr//PSbctXkDTuQUyZHNOXblb8vFmgBOeAFiNn5/3zbLTYgs5bRupu47Fc1i
4IIPr0jJJ0km+gnrGxMpzZASiGYA943j0rw3NGZf2CvTZomAdW665N3OZgk6jK7J
rZ8EhBpeRiMnp6I9E7jozZLkxHxjudQjhhiPAroW1obArqD7BtK+FdH5ywdJO1yF
lM1eMQ3ShhMISEnonbJkv5Mlai50upuYbmRdAokQmoONEG0xgO10kVqWVAZynDC1
dLNw0bmXJRaAAPyqlIhU
=z8/s
-----END PGP SIGNATURE-----

--=-vV0PYM8H2g365e1FqTYt--
