From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for March 1 (bluetooth/hci_sysfs)
Date: Tue, 2 Mar 2010 12:15:26 +1100
Message-ID: <20100302121526.36a1ea88.sfr@canb.auug.org.au>
References: <20100301210210.c6f465e6.sfr@canb.auug.org.au>
	<4B8C2CC5.8000603@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__2_Mar_2010_12_15_26_+1100_x6.bYRwK6xFgMQ=b"
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-bluetooth@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4B8C2CC5.8000603@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__2_Mar_2010_12_15_26_+1100_x6.bYRwK6xFgMQ=b
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Mon, 01 Mar 2010 13:08:21 -0800 Randy Dunlap <randy.dunlap@oracle.com> w=
rote:
>
> static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
> 						size_t count, loff_t *ppos)
> {
> 	struct hci_dev *hdev =3D file->private_data;
> 	struct inquiry_cache *cache =3D &hdev->inq_cache;
> 	struct inquiry_entry *e;
> 	char buf[4096]; // <<<<<<<<<<<<<<<<<<<<<<<<<<< huh? don't do that on sta=
ck.
> 	int n =3D 0;

Dave Miller is following up on that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__2_Mar_2010_12_15_26_+1100_x6.bYRwK6xFgMQ=b
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuMZq4ACgkQjjKRsyhoI8wekQCeM8K375Jt7YKI2HRifcC9lXHS
Z7UAnir+PiJ7hIHWbXeWGtTWQcH9yjXu
=QUPf
-----END PGP SIGNATURE-----

--Signature=_Tue__2_Mar_2010_12_15_26_+1100_x6.bYRwK6xFgMQ=b--
