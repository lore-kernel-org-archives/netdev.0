From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the driver-core tree with the net
 tree
Date: Fri, 21 May 2010 16:38:44 +1000
Message-ID: <20100521163844.c702a2b4.sfr@canb.auug.org.au>
References: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__21_May_2010_16_38_44_+1000_fHd6_1MLdCRGZTiQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_May_2010_16_38_44_+1000_fHd6_1MLdCRGZTiQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

On Fri, 21 May 2010 16:21:34 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Today's linux-next merge of the driver-core tree got a conflict in
> net/core/net-sysfs.c between commits
> 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive Packet Steering")
> and fec5e652e58fa6017b2c9e06466cb2a6538de5b4 ("rfs: Receive Flow
> Steering") from the net tree and commits
> bc28c84244da26bafb0d3bce95ef45212b31c6b8 ("net/sysfs: Fix the bitrot in
> network device kobject namespace support") and
> 83dc0fbf37495691219d019ec16b40d8592d2956 ("net: Expose all network
> devices in a namespaces in sysfs") from the driver-core tree.
>=20
> I fixed it up (I think - see below) and can carry the fix as necessary.

The net tree has been merged by Linus, so this should be fixable in the
driver-core tree now.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__21_May_2010_16_38_44_+1000_fHd6_1MLdCRGZTiQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkv2KnQACgkQjjKRsyhoI8ykJgCfd5vyX0JpiD9mNzCBu2zsk8/J
Z7AAn3WkgSXLNe9Um8+K1S4ObxHpDRUe
=1kmK
-----END PGP SIGNATURE-----

--Signature=_Fri__21_May_2010_16_38_44_+1000_fHd6_1MLdCRGZTiQ--
