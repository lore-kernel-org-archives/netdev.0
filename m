From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next,v2,1/1] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Mon, 17 Mar 2014 20:27:59 +0000
Message-ID: <1395088079.22343.6.camel@deadeye.wl.decadent.org.uk>
References: <1394903887-30421-1-git-send-email-haiyangz@microsoft.com>
 <1394903887-30421-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5957516114320940894=="
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394903887-30421-2-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org


--===============5957516114320940894==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yVArXfb1FmlmdvVqE1vx"


--=-yVArXfb1FmlmdvVqE1vx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-15 at 10:18 -0700, Haiyang Zhang wrote:
[...]
>  #define RING_SIZE_MIN 64
> -static int ring_size =3D 128;
> +int ring_size =3D 128;
>  module_param(ring_size, int, S_IRUGO);
>  MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");

You have to add some driver-specific prefix to the variable name if it
is going to be extern.  (And use module_param_named to avoid changing
the parameter name too.)

[...]=20
> +u8 hash_key[HASH_KEYLEN] =3D {
> +	0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2,
> +	0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0,
> +	0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b, 0x30, 0xb4,
> +	0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30, 0xf2, 0x0c,
> +	0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa
> +};
[...]

Same for this one.

Ben.

--=20
Ben Hutchings
I'm always amazed by the number of people who take up solipsism because
they heard someone else explain it. - E*Borg on alt.fan.pratchett

--=-yVArXfb1FmlmdvVqE1vx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUydaz+e/yOyVhhEJAQr9kw/8Dpd6WRrIDCpqSPHGR/LftStCmr/Ydt7v
88ymlvRcIbdwDH46A/a9+Wd3SB874TTBxFhjEoVpskfSA1+VxHlFOFgpjXEs+CT+
EfIKwFJZQcvM5TWZvLN1tFbE/oYmEkDCyHJh8UeDMjVArvm5WrcxdC0HLB3cX+Fo
v0RdomQBf9LOobCzQ728uN9vBZ56wvicFsD/1yuyuqDpO/SygSpgE8gxJazT3v6H
xUrlZnwRDX3r2XSaYuNjAHNakpmep6uz2kPh+qYF9VFqtq8Kzu9gC9Yp/bPwUCB1
lComZpaEPIJDCgjO71dEQ+HaZkyosWUIRDglutw6jNEAw/Sx6/+15m53xUg0VYRY
1XjY7TKPu90leg+Vkl9ceGmNevm7WUYLTkNbpVT0Q0/pQ0X5PyrbJ+hUIMSV2Z1/
YhYWFCMRBJOZ7D/zDPKSAaRm4YC7Ep4pOuItW7pUPNEKkxj/p7TbLIPZd1oKn0Fo
s01+wLwIXTFee79tF4X86uZmY8qWeRoUwLIJaLvlysjTStmTSCSGCYuJ7nlVZRDD
bG1lQ/GYCKr0NOE4Grt6jxSOTf2C1ZW2XlbUJ3GhDehnIbC9fdLvFGoFbKHgQ2Ys
mOpQqy76Ru+ukJlOhy6HC0GHn3vAh7Zcfbpsn3ePbj4bU0v7hqngTOSsiVSwxcLy
B+k0Z0wDniE=
=jc4a
-----END PGP SIGNATURE-----

--=-yVArXfb1FmlmdvVqE1vx--

--===============5957516114320940894==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============5957516114320940894==--
