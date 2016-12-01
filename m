From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net v2] tipc: check minimum bearer MTU
Date: Thu, 01 Dec 2016 16:11:18 +0000
Message-ID: <1480608678.16599.94.camel@decadent.org.uk>
References: <20161201110205.10749A0F33@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-Biy9DTYMur2sY1fuSzer"
Cc: "David S. Miller" <davem@davemloft.net>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Qian Zhang <zhangqian-c@360.cn>
To: Michal Kubecek <mkubecek@suse.cz>,
        Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201110205.10749A0F33@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Biy9DTYMur2sY1fuSzer
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-12-01 at 12:02 +0100, Michal Kubecek wrote:
[...]=C2=A0
> +/* check if device MTU is sufficient for tipc headers */
> +static inline bool tipc_check_mtu(struct net_device *dev, unsigned int r=
eserve)
> +{
> +	if (dev->mtu >=3D TIPC_MIN_BEARER_MTU + reserve)
> +		return false;
> +	netdev_warn(dev, "MTU too low for tipc bearer\n");
> +	return true;
> +}
[...]

The comment says "check if ... sufficient" but the return value
indicates the opposite.  Could you make these consistent?

Other than that, this looks OK to me.  I haven't tested any version as
I don't know how to use TIPC.

Ben.

--=20
Ben Hutchings
A free society is one where it is safe to be unpopular. - Adlai
Stevenson


--=-Biy9DTYMur2sY1fuSzer
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlhAS6YACgkQ57/I7JWG
EQm8QhAAo5oQRfO7tJwppiPCwNpEkJyOQb6kDACImO09iQAu321/5UKEKzLDIA2q
mTqfyVQIIG9O0tQWBK34i+rxV+RDsQ6Ei2BEh0S+/3fPfqyThcxA5QqtDb0oeJfr
YVBP7w7n6HDgLlm/YxK/UASUtxNlXaDmuZBkScKS3QND/bFdpFU5n9Zt5lBbiZQI
tOeAGdONfDElDFzO2yMyavLmfd0yIgQPJzCJzjS1XlJJLrLP9X6hCEd4ToNAb/lC
1mJK3F0TCx4yNZC8TgQYuJV61QFKuZUuoD5AUIvxaDSy6ilyS7Yp0EnEqGTiKPak
Zzn+TKSlfbKXWLlNk52itdUJfYOpWLOYAPQg/yJiD2DsqEJ3LGv80FBjqdwdzY+v
MuQ5dd2IrccMqjx1bNW7zf9TaGhKmkSqUXwCXLGh3CM73+2ZwTTBnGvYuokckv9G
PRiTiFA74wEpFEDLRJ+h0Zsqftu7iCzEp5a3PKHAoVbMqV2eIlkiWNeBXB+KnXbp
z76R3Iqxp6IUmfU1DrrVeLQ4xli5/6O1FzE/ETz30RSh0y/NBgBZfQ4mJSV363fu
iECOOP11+i24I5+L29I6Tlr+V1+drJ27xzn2wnDRolLNCS6jMbLe8qp3qxdQLtXR
GOrESrKauIXZDjsxycKOjz/GpWptjLmiptCXRGmLglU/Uj3VPBM=
=7W3G
-----END PGP SIGNATURE-----

--=-Biy9DTYMur2sY1fuSzer--
