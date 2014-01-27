From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the bluetooth tree with the
 net/net-next trees
Date: Tue, 28 Jan 2014 09:54:15 +1100
Message-ID: <20140128095415.8382335c33545ad14d4be067@canb.auug.org.au>
References: <20140107125418.986ae20298ddc55e5e657447@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__28_Jan_2014_09_54_15_+1100_9.C+37tbD.O6vAfb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>
To: Gustavo Padovan <gustavo@padovan.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140107125418.986ae20298ddc55e5e657447@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__28_Jan_2014_09_54_15_+1100_9.C+37tbD.O6vAfb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 7 Jan 2014 12:54:18 +1100 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> Today's linux-next merge of the bluetooth tree got a conflict in
> net/ieee802154/6lowpan.c between commit 965801e1eb62 ("net: 6lowpan: fix
> lowpan_header_create non-compression memcpy call") from the  tree and
> commit 8df8c56a5abc ("6lowpan: Moving generic compression code into
> 6lowpan_iphc.c") from the bluetooth tree.
>=20
> I fixed it up (I applied the following patch to move the fix into
> 6lowpan_iphc.c) and can carry the fix as necessary (no action is
> required).
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 7 Jan 2014 12:52:43 +1100
> Subject: [PATCH] net: 6lowpan: fixup for code movement
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/ieee802154/6lowpan_iphc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
> index 11840f9e46da..e14fe8b2c054 100644
> --- a/net/ieee802154/6lowpan_iphc.c
> +++ b/net/ieee802154/6lowpan_iphc.c
> @@ -677,7 +677,7 @@ int lowpan_header_compress(struct sk_buff *skb, struc=
t net_device *dev,
>  			hc06_ptr +=3D 3;
>  		} else {
>  			/* compress nothing */
> -			memcpy(hc06_ptr, &hdr, 4);
> +			memcpy(hc06_ptr, hdr, 4);
>  			/* replace the top byte with new ECN | DSCP format */
>  			*hc06_ptr =3D tmp;
>  			hc06_ptr +=3D 4;
> --=20
> 1.8.5.2

I think this fix patch got missed when bluetooth was merged ... so it
should probably go into the net tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__28_Jan_2014_09_54_15_+1100_9.C+37tbD.O6vAfb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS5uObAAoJEMDTa8Ir7ZwVSkoP/RfvqDurol0Qhki0tzIlWWUy
sMgkoah19nmjzew2hPLLmaI0cBv3yrwUPWIjbI6GMRsOGOivykMaj69ER7DNqnhO
fg79SsahBBihw50kja9mx/KWBcQt6vxXZZMVd1a+UWOwSKnsf5I2gaIJMsvhIfCB
CsIas+O0WZ385pAyjqK/uvRNM4lX3mIXuRInybGqYXlLY8NgMMAyU3bvuqLtt6Jm
DNL45fjGxMRsuaGGTgVfw4k3W4eILS4NvSzsz/MDesaJbEQ2g7OkmpbIPY494OhL
MQs5tqe6tvst1aVpd+ouYCCAWrkktcMq118iUwoNfBuNrEtqmw9thWFFRry1T2AQ
Imw7g8lxnqB8RKTsljAo9+r+chpMEuX4EsT9WPmQO2xYG4d4uDNB3GpPIvIjoZWe
S7Ryy8DNocLbKQbvq0ko9VRleCbfBgVwKsLVr94wrsGrLrnU6D4TOCZJA1MzPLh8
53LvIGEADbinHWBwYpuZ4NCWdMzjk99fs/0Gi31TqF7kPvSdUeMUablPvycHd/Gq
t8vZeY4Rzp35IUlc8upqU+DQiAp2OLzfnj9uWcBSTX1T+47RAGLV2+zAzlKhEA81
7n01JWCSBm5ID5o1tOWcrK5NAmVI4jwd5N4u6iFbGllDbsHbr9TvSiMRSLzQhoNj
Djmzf+ThlWD1iEAKVwaZ
=qH/o
-----END PGP SIGNATURE-----

--Signature=_Tue__28_Jan_2014_09_54_15_+1100_9.C+37tbD.O6vAfb--
