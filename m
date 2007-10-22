From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 11:26:05 +0200
Message-ID: <20071022112605.11f7893e@poseidon.drzeus.cx>
References: <20071022092350.5c75b3bd@poseidon.drzeus.cx>
	<20071022.013105.74746322.davem@davemloft.net>
	<20071022104208.78c79467@poseidon.drzeus.cx>
	<20071022.020538.74751031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-19709-1193045136-0001-2"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:34507 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbXJVJ0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 05:26:16 -0400
In-Reply-To: <20071022.020538.74751031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-19709-1193045136-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Oct 2007 02:05:38 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Pierre Ossman <drzeus@drzeus.cx>
> Date: Mon, 22 Oct 2007 10:42:08 +0200
>=20
> > This seems like a rather evil layering violation.
>=20
> This has a 10+ year precedence and it's why the Linux networking stack
> is so fast.  If you read any other driver you would have seen the
> skb_reserve() call every one of them do to align the headers.
>=20

The norm seems to be to not comment this call. It's hardly obvious.

> I think I've tolerated this long enough.
>=20
> Are you going keep teaching me how the C language works, how GCC
> interprets it, and how evil the Linux networking is, or are you going
> to fix the bug in your driver? :-)

Settle down, "bug" fixed even before this discussion even began. I just don=
't like papering over problems so I want to know why this is needed and if =
it isn't indicative of a larger problem. If you don't want the discussions,=
 make sure people know the gotchas.

(And I wasn't try to teach anyone. I was giving my view on things, and if y=
ou think I'm off my meds, feel free to say so. Groveling and excessively pu=
tting every statement as a question demeans us both. ;))

Rgds
Pierre

--=_hera.drzeus.cx-19709-1193045136-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHHGyt7b8eESbyJLgRAqHvAJ4kMMXfR7+E3L7bxPd5Cn0mDXbuEQCgtzCX
06Kt29ii5ZRj0WlLCJiYYWs=
=uukx
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-19709-1193045136-0001-2--
