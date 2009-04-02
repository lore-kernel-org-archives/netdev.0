From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 09/17] net: Add vbus_enet driver
Date: Thu, 02 Apr 2009 07:43:53 -0400
Message-ID: <49D4A4F9.6090007@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>	<20090331184334.28333.8415.stgit@dev.haskins.net> <20090331133952.280373e9@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAA7E937832300ACF99B30BC8"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090331133952.280373e9@nehalam>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAA7E937832300ACF99B30BC8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger wrote:
> On Tue, 31 Mar 2009 14:43:34 -0400
> Gregory Haskins <ghaskins@novell.com> wrote:
>  =20
>> +struct vbus_enet_priv {
>> +	spinlock_t                 lock;
>> +	struct net_device         *dev;
>> +	struct vbus_device_proxy  *vdev;
>> +	struct napi_struct         napi;
>> +	struct net_device_stats    stats;
>>    =20
>
> Not needed any more, stats are available in net_device
>
>  =20

Thanks for the review, Stephen!

I will apply all of your recommended fixes for the next release.

-Greg


--------------enigAA7E937832300ACF99B30BC8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUpPkACgkQlOSOBdgZUxnbaACghpNAi0j4PvZA/bSa+MXHX9Ya
roAAnik2nojK8G3BB+E+zqYlzG9WCpnt
=Exds
-----END PGP SIGNATURE-----

--------------enigAA7E937832300ACF99B30BC8--
