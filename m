From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build()
Date: Fri, 21 Oct 2016 16:00:05 +0100
Message-ID: <1477062005.2670.5.camel@decadent.org.uk>
References: <20161019021654.GD2773@decadent.org.uk>
         <6a69780d-0797-b5af-fc90-04960bbb21c6@gmail.com>
         <1476967585.2709.52.camel@decadent.org.uk>
         <A2BAEFC30C8FD34388F02C9B3121859D22587ADA@eusaamb103.ericsson.se>
         <1476981609.2709.56.camel@decadent.org.uk>
         <A2BAEFC30C8FD34388F02C9B3121859D22588579@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-SEn+7Q+oE8wKIe8YeqcV"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Qian Zhang <zhangqian-c@360.cn>,
        Eric Dumazet <edumazet@google.com>
To: Jon Maloy <jon.maloy@ericsson.com>, Ying Xue <ying.xue0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49216 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934303AbcJUPAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 11:00:18 -0400
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D22588579@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SEn+7Q+oE8wKIe8YeqcV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-10-21 at 14:57 +0000, Jon Maloy wrote:
> > -----Original Message-----
> > > > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Thursday, 20 October, 2016 12:40
> > > > To: Jon Maloy <jon.maloy@ericsson.com>; Ying Xue <ying.xue0@gmail.c=
om>
> > > > > > Cc: netdev@vger.kernel.org; Qian Zhang <zhangqian-c@360.cn>; Er=
ic Dumazet
> > > > <edumazet@google.com>
> > Subject: Re: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build=
()
> >=20
> > On Thu, 2016-10-20 at 14:51 +0000, Jon Maloy wrote:
> > [...]
> > > > At this point we're about to copy INT_H_SIZE + mhsz bytes into the
> > > > first fragment. =C2=A0If that's already limited to be less than or =
equal to
> > > > MAX_H_SIZE, comparing with MAX_H_SIZE would be fine. =C2=A0But if
> >=20
> > MAX_H_SIZE
> > > > is the maximum value of mhsz, that won't be good enough.
> > >=20
> > >=20
> > >=20
> > > MAX_H_SIZE is 60 bytes, but in practice you will never see an mhsz la=
rger than
> >=20
> > the biggest header we are actually using, which is MCAST_H_SIZE (=3D=3D=
44 bytes).
> > > INT_H_SIZE is 40 bytes, so you are in reality testing for whether we =
have an mtu
> >=20
> > < 84 bytes.
> > > You won't find any interfaces or protocols that come even close to th=
is
> >=20
> > limitation, so to me this test is redundant.
> >=20
> > But I can easily create such an interface:
> >=20
> > $ unshare -n -U -r
> > # ip l set lo mtu 1
> >=20
> > Ben.
>=20
>=20
> It won't be very useful though. But I assume you mean it could be a
> possible exploit,

Exactly.

>  and I suspect a few other things would break both in TIPC and in
> other stacks if you do anything like that. I think the solution to
> this is not to fix all possible places in the code where this can go
> wrong, but rather to have a generic test where we refuse to attach
> bearers/interfaces offering an mtu < e.g. 1000 bytes. This can easily
> be done in tipc_enable_l2_media().

Yes.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of
them.


--=-SEn+7Q+oE8wKIe8YeqcV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYCi11AAoJEOe/yOyVhhEJfLAP+gIOeaef34ovedhBaGPmMUmf
xGsn399AJ/xxcXssbAw09LT+tgJL+4mA9KV81em5eaJGwlfVwjTyg3vumFvaqZrj
oQ/yJgZFJF/FXcdXKi2EVt/1OOxJTYINQ5EEG76Y6KGgRxgy/C6D37SxuugCJcz/
FdjMgfnzdTwe0Sg/LJcjNW4Fe1b8VdtIQUTjp4z8fPXWtMaz3xwuE9gYbyYwq2XO
tqLOeGeqiv2z6Aqo9B/tBXjB6/A9nbmI/92fwM7jQSG6JbRHc0BKBLch81DRmTq3
i/qQ7t41q/riKtefQQgVkOjpb5MxC2z3xX5jnMcHPxXN4MwFV1sL2Ry/Q9S4acVM
az4xVSwq2u1hUfqpv02Qhq4ejS+Aq3FFjBCfnlQg109ugyptarPPWlnLJFjT8NzU
P+ml3YjqUmEAJzmoL++VODhRSZ1/Rwqry5FYTDzVg57Av4ybYOHei0mrw5GPO5JE
qo1MCEtsr1wyetiyuh7aCKZr3yKyDeNLEBjsz5nnV8cyz5rIx98ugf9tNypcJWsN
PhdLwm1fAxM3Ik3wajiub/R4sPhcvOTnyZzHnQsGZZniWejbAxzdLYuSNtfXIlok
VxQUasDneALvjdpLgnJU0cZAQva45T0dx7plQr3ymFkRNUPdlBZIEIeIPykUhIi5
xGNXwy94uheH48CFK1Dz
=h49h
-----END PGP SIGNATURE-----

--=-SEn+7Q+oE8wKIe8YeqcV--
