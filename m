From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH] ethtool: Add Direct Attach to the available
 connector ports
Date: Mon, 30 Nov 2009 12:35:13 +0000
Message-ID: <1259584513.3709.173.camel@localhost>
References: <20091125101315.24481.11759.stgit@localhost.localdomain>
	 <20091129.003601.253425360.davem@davemloft.net>
	 <4B125014.9080507@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-syPxzdReJvoCh7GjxOT4"
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com,
	=?ISO-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57656 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751416AbZK3MfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 07:35:18 -0500
In-Reply-To: <4B125014.9080507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-syPxzdReJvoCh7GjxOT4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-11-29 at 05:42 -0500, Jeff Garzik wrote:
[...]
> I've been trying to think of what would be a good versioning scheme for=20
> ethtool.  Even though it is [essentially] a user-friendly kernel=20
> interface, its releases have never really been closely synchronized with=20
> the kernel releases.  And unlike a lot of other software, ethtool is so=20
> simple it does not really go through any release-candidate or beta period=
.
>=20
> The current scheme just increments a release number: 5->6, 6->7, etc.=20
> But with so few kernel releases (and thus ethtool releases), I was=20
> leaning towards either yearly release naming ("ethtool-2009"), kernel=20
> release naming ("ethtool-2.6.33"), or the release scheme proposed for=20
> glibc:  snapshot directly from the git repository.
>
> If people want one, I could do a release right now.  Or, we could move=20
> to an alternate scheme like git snapshots.  I think git snapshots are=20
> viable because ethtool has historically had next to zero bugs in the=20
> actual userland utility.  Fedora already imports git snapshots, for examp=
le.

So does Debian.  But this is because we need to include the new
features, not because we like using snapshots.

> Preferences?

I think it should be based on kernel versions, so that it's clear
whether a given ethtool version supports the features introduced in a
given kernel version.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-syPxzdReJvoCh7GjxOT4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASxO7/+e/yOyVhhEJAQIENA//Q6RqOVfByqm558N610QQBmfT7V93D3xO
TR0TV80TVFX+p/IG7Qd5JlQ33+dHpXOB5p2ab6BZzHKOQCeV+RMP8Sc6fH+Iwn35
s6NycQRJyHmwIz1rcHspo/QBIRRkXTx8aNjTgacRIWW0KjjoWSrZjhS8M/DyAIcx
BiO15llCAlqBoOfdepajsn5+MDAiwdt8WQQUr0wHheGJYkYFVz6kS3rqbocjAPcU
S95XzxbT3efFuyU5xL1Dv8CPHPjDw1YYkhntfyt4tB7n13lG176QJlBzeGvNMPWQ
Vv3+cVrwlfPHrwhLIOfCQnw7YWuVoLLN5nBJ1peq1RSKUUqHTkk8t0imAQsQT6hi
PI0SqKkwqH6iVeRdq80UfuN5dNjk7bbILwmJV/2qDCZUg6/f+lyOHS862C+nQlkG
Vpmv87qETh1P/6mJFPjQir90VPROonzmTr3cISYKIGVtH8wLcvFcJGN+XpINFvAH
D4ybzTaD7R+umvTVpsJI8EeXvLjc765ozHDn5KcZ8RW2l2CpkgeX9ZrZi4WtuGV8
lhaehEfCOJVzHarUGK7KStzjB0KdlhIGV/OLa5mbWaulTzFiznMa0Ic/21Oj5+P7
qNZKP+mvdobBZgoRYdCOehqwT5v6KhYJYcc4x2s268lZhkYtn5vrqkU7xrGDdMwR
ZSNEQWdWYes=
=satH
-----END PGP SIGNATURE-----

--=-syPxzdReJvoCh7GjxOT4--
