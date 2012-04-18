From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 10/11] batman-adv: print OGM seq numbers
 as unsigned long
Date: Wed, 18 Apr 2012 09:24:50 +0200
Message-ID: <20120418072449.GE27966@ritirata.org>
References: <1334663907-22725-1-git-send-email-ordex@autistici.org>
	<1334663907-22725-11-git-send-email-ordex@autistici.org>
	<20120417.224746.802445483718191876.davem@davemloft.net>
	<20120418064659.GC27966@ritirata.org>
	<20120418070134.GD27966@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C94crkcyjafcjHxo"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120418070134.GD27966-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--C94crkcyjafcjHxo
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 18, 2012 at 09:01:35AM +0200, Antonio Quartulli wrote:
> On Wed, Apr 18, 2012 at 08:47:00AM +0200, Antonio Quartulli wrote:
> > On Tue, Apr 17, 2012 at 10:47:46 -0400, David Miller wrote:
> > > From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> > > Date: Tue, 17 Apr 2012 13:58:26 +0200
> > >=20
> > > > OGM sequence numbers are declared as uint32_t and so they have to p=
rinted
> > > > using %u instead of %d in order to avoid wrong representations.
> > > >=20
> > > > Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> > >=20
> > > Fix this commit message subject, "%u" is "unsigned int" not
> > > "unsigned long"
> > >=20
> > > "unsigned long" would be "%lu"
>=20
> There is a problem here. On my machine (x86_64) I have:
>=20
> typedef unsigned int __u32;
> typedef         __u32           uint32_t;
>=20
>=20
> So I should use %u to print my uint32_t variable (as I reported in my com=
mit
> message).
>=20
> Probably this is not the case on each and every architecture?
> If so, how could I handle it?

Ok. After digging in the code again I understood that the problem is either=
 in
my brain and in the commit subject.

I'll fix both.

Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--C94crkcyjafcjHxo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPjmxBAAoJEFMQTLzJFOZFF+gH/jhv/ONO/l4Z1NJN8G08CQXr
7VMwLcuSyK+InjoNvZ47nFfJfzn3EwjdiFKvTUhVBgr43NsRvk5o9gWppA8z/XRc
IBFmTMGiOXjvc/W+9p06PywEa7uyCg1pHMZHDgsREhk3+KX7wsdmckG3gJppYV0f
gVeDMZKdhfg8o1ZihWCdFIZPBSYs1xov/uNAEFci4tDtT0KwKgF3NuQLG74BD5JJ
rJhjFaFLd4ZtpRlVJhdS2Prdk//XUgBGpOgQrCxeWippQZlenFaYUnhl8KJkuuJu
PY8KYfGtSFsXP//QwNwjSlWoeHSKtr11EesoS8Jb5vKitTD6aesQJ2ACjZNMA3U=
=OeLZ
-----END PGP SIGNATURE-----

--C94crkcyjafcjHxo--
