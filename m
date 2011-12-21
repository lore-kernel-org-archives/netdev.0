From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/8] farsync: Fix confusion about DMA address and buffer
 offset types
Date: Wed, 21 Dec 2011 05:41:13 +0000
Message-ID: <1324446073.2844.190.camel@deadeye>
References: <1324430940.2844.144.camel@deadeye>
	 <1324431172.2844.147.camel@deadeye>
	 <20111220.234656.658595607282312696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-twrbCDpmnZPfVRp7A4XA"
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111220.234656.658595607282312696.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-twrbCDpmnZPfVRp7A4XA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-12-20 at 23:46 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 21 Dec 2011 01:32:52 +0000
>=20
> > -	dbg(DBG_RX, "In fst_rx_dma %lx %lx %d\n",
> > -	    (unsigned long) skb, (unsigned long) mem, len);
> > +	dbg(DBG_RX, "In fst_rx_dma %x %x %d\n", (u32)skb, mem, len);
>=20
> This is more appropriately fixed by using "%p" instead of casting
> to a 32-bit int.

'skb' is the physical address of the data in the skb.  Whereas 'mem' is
the offset of the corresponding buffer in shared memory.

All completely clear, right? ;-)

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-twrbCDpmnZPfVRp7A4XA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATvFxeee/yOyVhhEJAQqN+hAA0R0buHs4pfmomXfNyjlDWvZUdrvoHh9k
tXrVDPaHQgotIRbsCTOwmXC55JGd3O9vsJgGk70df8Y/OTygXqHsLmlxwyRoe2lT
NU+sonkKBJYmoIR4UIdENGRxKy2E1ABJdBlBZY0Iwt55Pw+VORzSVECU59uTn7OQ
aAg+Z+z4a9m5+56JlafMlwKN4UeKBSDDC1XPveeULgawovtt1anTilw2Nl+f7Jb7
5u+fo7rQ4PjRPkv4CxUUpa8T8WemAPS39VPAwiWVC4qex6ussMxOhKQyb5hC4nrt
oX7muBFUbjwhE7sonN77eCw5wI5Uwqp0aZ23br+svPdFZgq6zDWvaIRBKUfGCW6l
S8qsotxwr0EryQjw+OU+D5zdpMto3YzUnkwu6OrAnSiuvc5+KI+W4GZN178k2q44
OKWjPbAtxQ7vjnKmdOWTOw0XNIikE+IDqG7NDah+whX0rXA5vGQghP1F5IdrbrT0
zcE1TKMVkiX6/ytZm9il1HP9BMDVslhcoz9CbXUKGuL97ycL7azDgQxHkVHmUryC
tDxEyzp4fwyiorxKcGDo7PUjKXCPjyjyzJ8qO/lBhCwMTM8XV4ji4OqUdVCtdPKP
3Qo9kh1+qvmkJTrGeYO9ZuMdBaTbfyuCuJ7iQz4D+ELF92A8U/V+T/4Mro+VYRo8
AKxnHmRs6yE=
=WHuV
-----END PGP SIGNATURE-----

--=-twrbCDpmnZPfVRp7A4XA--
