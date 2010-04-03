From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Sat, 03 Apr 2010 17:05:56 +0100
Message-ID: <1270310756.12516.308.camel@localhost>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	 <ac3eb2511003301153i43a60720hb015071e2c992199@mail.gmail.com>
	 <m14ojxh0mz.fsf@fess.ebiederm.org>
	 <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
	 <1270256303.12516.234.camel@localhost>
	 <h2gac3eb2511004030135q2a2f5002z912974c1d2ab8853@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wpd++Y0TrYLBEsvuVVoI"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <h2gac3eb2511004030135q2a2f5002z912974c1d2ab8853@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wpd++Y0TrYLBEsvuVVoI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-04-03 at 10:35 +0200, Kay Sievers wrote:
> On Sat, Apr 3, 2010 at 02:58, Ben Hutchings <ben@decadent.org.uk> wrote:
> > On Wed, 2010-03-31 at 07:51 +0200, Kay Sievers wrote:
> >> Yeah, /sys/bus/, which is the only sane layout of the needlessly
> >> different 3 versions of the same thing (bus, class, block).
> > [...]
> >
> > block vs class/block is arguable,
>=20
> That's already done long ago.
>=20
> > but as for abstracting the difference
> > between bus and class... why?
>=20
> There is absolutely no need to needlessly export two versions of the
> same thing. These directories serve no other purpose than to collect
> all devices of the same subsystem. There is no useful information that
> belongs to the type class or bus, they are both the same. Like
> "inputX" is implemented as a class, but is much more like a bus.

Really, how do you enumerate 'input' buses?

> And "usb" are devices, which are more a class of devices, and the
> interfaces and contollers belong to a bus.

What common higher-level functionality do USB devices provide?

> There is really no point to make userspace needlessly complicated to
> distinguish the both.
>=20
> We also have already a buch of subsystems which moved from class to
> bus because they needed to express hierarchy between the same devices.
> So the goal is to have only one type of subsystem to solve these
> problems.

That's interesting.  Which were those?

[...]
> > So while buses and classes both define device interfaces, they are
> > fundamentally different types of interface.
>=20
> No, they are not. They are just "devices". There is no useful
> difference these two different types expose. And the class layout is
> fundamentally broken, and not extendable. Peole mix lists of devices
> with custom subsystem-wide attributes, which we need to stop from
> doing this. The bus layout can carry custom directories, which is why
> we want that by default for all "classifications".
[...]

I understand that you want to clean up a mess, but how do you know
you're not going to break user-space that depends on some of this mess?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-wpd++Y0TrYLBEsvuVVoI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS7dnWue/yOyVhhEJAQLOSg/9GbfJ9o+ctZZa4vpK/i5Svwe5YMzn2dO8
6xth7JkusARINJHtFu/LOUZftzcsvC7RbWp3mWP3h33FtUmlqRv0lKvZEb4/+oVd
yjrJ+/gutCWQiSnYjfgutTa1B8qEV52161Gvrm6S7qDII5XVxGlIkRDuoDMO4P/A
FDZtAInBwSytp6pUzTKasNwgGi/BDWrpxOuH96eWozgcgqj/lwgccAvApiGUBN7x
/8/Q035mvmGiiNwFiZz18v/gPlwXSIc5GmsTL/ahu8CKT7wNP8EqLxrIbcCGLLqm
Zv+ncaMNsHwRE9FGL2gkTe3w2l6CLpqxiARLqUwXJmWIABJXAhVqaAHKjG2avZnR
NV0Wp9RTDIoL4vo2rneJml+JXS4K1tZr19RtTdSEq6I7tYS2DZ0euF+mWYt+F3SA
sQO3OWgWf+Q36NKnn64l4QmxT8q4aK5aHDncxLWL2D7Rydfxgkb/2zyoSBJ1T9mq
wyodtR8uS26rooGGkJieyotFzJoaSkBVpgJydHxLj2iWdDXIZTiEZXyJbaJa9OaV
bSej7ypaUHe3ReH6oOeGeQb5ZdJqg71Y581pVeP6ZJIjk71+sPPWGWQqaE+7YPDs
57d+/WgHrsakL/EtZpIsmySpymcijpNaOXwnluG8b7KKnJWS5RzIyGfLWGyVb2pE
nUxOsTSXnj0=
=Bf9e
-----END PGP SIGNATURE-----

--=-wpd++Y0TrYLBEsvuVVoI--
