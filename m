From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/mlx4: avoid a -Wmaybe-uninitialize warning
Date: Wed, 14 Dec 2016 12:13:43 -0500
Message-ID: <8fd869a2-9e7b-bba7-5cf0-af1d078016b6@redhat.com>
References: <20161025161632.411899-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="SSHcWMGwuWvVLst1UNIIORW2Xfrc2udHX"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Moshe Shemesh <moshe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Christophe Jaillet <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>,
        Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161025161632.411899-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SSHcWMGwuWvVLst1UNIIORW2Xfrc2udHX
Content-Type: multipart/mixed; boundary="NOme76SgKCRES5Eh7VA70OS1RG2iAVt9k";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
 Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Moshe Shemesh <moshe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Christophe Jaillet <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>,
 Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <8fd869a2-9e7b-bba7-5cf0-af1d078016b6-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/mlx4: avoid a -Wmaybe-uninitialize warning
References: <20161025161632.411899-1-arnd-r2nGTMty4D4@public.gmane.org>
In-Reply-To: <20161025161632.411899-1-arnd-r2nGTMty4D4@public.gmane.org>

--NOme76SgKCRES5Eh7VA70OS1RG2iAVt9k
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/25/2016 12:16 PM, Arnd Bergmann wrote:
> There is an old warning about mlx4_SW2HW_EQ_wrapper on x86:
>=20
> ethernet/mellanox/mlx4/resource_tracker.c: In function =E2=80=98mlx4_SW=
2HW_EQ_wrapper=E2=80=99:
> ethernet/mellanox/mlx4/resource_tracker.c:3071:10: error: =E2=80=98eq=E2=
=80=99 may be used uninitialized in this function [-Werror=3Dmaybe-uninit=
ialized]
>=20
> The problem here is that gcc won't track the state of the variable
> across a spin_unlock. Moving the assignment out of the lock is
> safe here and avoids the warning.
>=20
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Thanks, applied.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--NOme76SgKCRES5Eh7VA70OS1RG2iAVt9k--

--SSHcWMGwuWvVLst1UNIIORW2Xfrc2udHX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYUX3HAAoJELgmozMOVy/devoQAMKv9d90uOxo+DtGGsMvAlGo
uJ7WNVEBd15szUlZTP8tu0JQn1/mPmvheWZhoRhtQUWMwUcBK1BZr4O3ZWNthqM8
8LqT6wXWsqkKwdh2QUJBHxVsxyL7WWCQSmzZMvaydAV8s5irOzjIyYpuv2gOtBgr
PS8AZ7+GS9jmKPsoZq+rvWKlDaTngmNZuGgSX32LL1AyEgbfRjH7xlUtPttnBsIe
n0FIphWNykmGCbYuXGJQ4qg/1QKAUsIMUz8AhtT56HAF+wdjnqilDPmgEe2yY0aY
NwpBtMMV34CDdBejbuDvBj+RmV2pbuehRJphWpvO8qCySPnw2oJQ7kQbk55sRtKE
cPd9xD1OIGJX3o7fzRtFebSr1W8QYIypafL58Y767XGvpF0PzUWSoBSZ2zw1m9Ys
qVmsdzZFlhWRDc2BldcjjEReCuhqJm3oXgRMPYfbQz3/JqJ1OExqiqPFbdyIs03i
QL9rbeEizTH+Pq2+CKmsmkAd0CW6PRlOaDg+HMVM7Eqq73p+OTdGK6Z5Vgj55Gvh
BkXW4o9/KKRYjkASHrYUBqgIxKmP1rBlPzRU7daXktuJSkQmUtP+3gVCF4APQRU8
hF7v1TT3VFiK6e2FAEPtLzsG6I0tS4BvR1VYTmGM3tss/safk1f5WO4tBHjs4WcH
aETraS0tQdJ/Wq41TaOf
=WGaN
-----END PGP SIGNATURE-----

--SSHcWMGwuWvVLst1UNIIORW2Xfrc2udHX--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
