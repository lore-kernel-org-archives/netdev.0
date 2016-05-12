From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH net-next 4/5] treewide: replace dev->trans_start update
 with helper
Date: Thu, 12 May 2016 15:40:46 -0400
Message-ID: <20118955-8739-b79a-e20e-96302e8b41bf@redhat.com>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285994-31983-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MxOQ9rEvBghhBiQvcDah4SfXu2ff5Ef0r"
Cc: user-mode-linux-devel@lists.sourceforge.net,
	linux-xtensa@linux-xtensa.org,
	linux1394-devel@lists.sourceforge.net, linux-rdma@vger.kernel.org,
	mpt-fusionlinux.pdl@broadcom.com, linux-scsi@vger.kernel.org,
	linux-can@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-hams@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org, devel@driverdev.osuosl.org,
	b.a.t.m.a.n@lists.open-mesh.org, linux-bluetooth@vger.kernel.org
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1462285994-31983-1-git-send-email-fw@strlen.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MxOQ9rEvBghhBiQvcDah4SfXu2ff5Ef0r
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/03/2016 10:33 AM, Florian Westphal wrote:
> Replace all trans_start updates with netif_trans_update helper.
> change was done via spatch:
>=20
> struct net_device *d;
> @@
> - d->trans_start =3D jiffies
> + netif_trans_update(d)
>=20
> Compile tested only.
>=20
> Cc: user-mode-linux-devel@lists.sourceforge.net
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux1394-devel@lists.sourceforge.net
> Cc: linux-rdma@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: MPT-FusionLinux.pdl@broadcom.com
> Cc: linux-scsi@vger.kernel.org
> Cc: linux-can@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linux-omap@vger.kernel.org
> Cc: linux-hams@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Cc: linux-s390@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Cc: b.a.t.m.a.n@lists.open-mesh.org
> Cc: linux-bluetooth@vger.kernel.org
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Checkpatch complains about whitespace damage, but
>  this extra whitespace already exists before this patch.
>=20
>  drivers/infiniband/hw/nes/nes_nic.c                    | 2 +-
>  drivers/infiniband/ulp/ipoib/ipoib_cm.c                | 2 +-
>  drivers/infiniband/ulp/ipoib/ipoib_ib.c                | 2 +-

For InfiniBand bits,

Acked-by: Doug Ledford <dledford@redhat.com>

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--MxOQ9rEvBghhBiQvcDah4SfXu2ff5Ef0r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNNw+AAoJELgmozMOVy/dVQcP/1RZvmqQVJpZMtptIm8OpoPW
4QrFlnjv+KorYVaF1Hg7+0X6yfCF53ofTKRAg4zaYiASZw4AJWYzslxA9b0OvpPS
TzMjJrbWm27+W2pH8ZivFepys9afxW5o/qb7CFYyOPOEml495zReUvTqt/nSh7jG
8nTdwO4xH5kY4P82bDn18Lyqd/8cS7yFl1OAK88eqq+y9JgveiIsO2PlsrtFENtX
+RyadCAluEUdfe6CZjMjUptBptIi6hfoMqmXXu4vcFs48mqbVf4QubFp5f+4wJa2
KScILHNil3156j3TY3lpG1ukf2SfF0UYDYxco5tZlZ3O7nB3Xteif94gvvUiszyO
IfGn3/wblQs6tRSHjMRNYiTVeYkyh0eXbdbha/7bkBG58mEjYFnrjtRuBMD2Ogmm
uz6MhyD6Ez7mKKVBc3ooQ6SYpcwb4surHEGm36a2Utnb/vftxyPYpA75neZbSGZO
X828tsNcxB9K8FUCEcP/Xasc5xE6kPtpwu5TIbJ7itYLs4yRoZbsmcI5UrhjqERp
YAAiI07vifFHyFLUnfAOefjXxQOFJdQHtMphlnjfYiKXSpJsAhT2LIJpepgbovCc
/268dPol/ul7WUbLu2P4zlnnIEQgABW6NKFMAg/N/b4XQ08VkeKv82yJ9aLuyG2J
0QbOFyrXnR/I1OYFeDAU
=2VMH
-----END PGP SIGNATURE-----

--MxOQ9rEvBghhBiQvcDah4SfXu2ff5Ef0r--
