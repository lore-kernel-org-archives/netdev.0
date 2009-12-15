From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 11:05:33 +0100
Message-ID: <1260871533.3692.5.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <20091215.014308.77044043.davem@davemloft.net>
	 <1260871411.3692.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-kqFjI5E4r06pCwylpKZ8"
Cc: daniel@caiaq.de, linux-kernel@vger.kernel.org, dcbw@redhat.com,
	m.hirsch@raumfeld.com, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759618AbZLOKF7@vger.kernel.org>
In-Reply-To: <1260871411.3692.4.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-kqFjI5E4r06pCwylpKZ8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-12-15 at 11:03 +0100, Johannes Berg wrote:
> On Tue, 2009-12-15 at 01:43 -0800, David Miller wrote:
>=20
> > > The effect is that after a number of mode transistions (sometimes as =
few
> > > as two sufficed), the kernel will oops at very strange locations, mos=
tly
> > > in something like __kmem_alloc().
> > >=20
> > > While the root cause turned out to be an issue with the wpa-supplican=
t
> > > which feeds the kernel driver with garbage, this occasion pointed out=
 a
> > > bug in the wireless wext core when SSIDs with 32 byte lengths are pas=
sed
> > > from userspace. In this case, the string is not properly NULL-termina=
ted
> > > which causes some other part to corrupt memory.

And, I forgot to mention, this is in fact not an issue or the "root
cause" of any issues -- it's completely intentional that wpa_supplicant
feeds the kernel with a random, valid, 32-byte SSID.

johannes

--=-kqFjI5E4r06pCwylpKZ8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLJ19oAAoJEODzc/N7+QmaDSwQAKyvrhzt3wtSVwUIWtgz5s/E
tvU3xwchXipmHLmD0EAD1uP50SOAvqkJ49gnBuZsiQoNj5fl/8gBRJCGGnJo4ADH
zCLOysfdKIin8IP0A/pPpMI06wn1jZ42e1vg45HnaJzFl4PbA++5b8DWXiZ3Nz/9
8TqRKGbnN8hgsFAT/nbE043Gv3b6mydtICDoHnvFzaalrOLEVYmYYzg6MCF92U/l
xaTF/vJPe/qAd+fcccWkBXgEYL48uBcEejDSnpbVgIaQ2euFj7maI/ifnYVIK2n+
xay7TIAQ9Zvjnk+VXhMDeOg6DqLcLcgJf+qNxobGjElsojJVCRp6037dlGuu4chj
QsawPj070qihbxl6WVefiTJcoocQFWsE0GAjTqbu0UdTu/FgWvr6vFwRg8uekFai
0KqIVhva3tm8yZCL2oGwfvIOvd1tpsqID6sauO8zV29g9C/JR29lXBJD1VQGQy/m
mESD2ye+vJHAH7lvc1lZg0qsijQa7XmVIKezLTQrxFRDkCvStG0Lr/Rao9UfgYAU
EJzEkacRQnpzuR9qXqQwtL3cLJnzbTvbwjh6U3Kn1uWmbm4TTNWayXp5kN+fOvky
vJrgnq68NetiyMRCE2eDTyl5k3X7bHaLDCT0MCfv+T4OcHIWOYoP+/JN5D25iCE5
dkNLtHpBd0T/XFUezuqC
=gIjA
-----END PGP SIGNATURE-----

--=-kqFjI5E4r06pCwylpKZ8--
