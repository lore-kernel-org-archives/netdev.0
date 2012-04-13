From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Fri, 13 Apr 2012 12:51:41 +1000
Message-ID: <20120413125141.24b117ae125e95843bc3689d@canb.auug.org.au>
References: <20120413123055.8d25d96b3d3c055b726b8519@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__13_Apr_2012_12_51_41_+1000_sQ7O8j1tzP30ksbh"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120413123055.8d25d96b3d3c055b726b8519@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__13_Apr_2012_12_51_41_+1000_sQ7O8j1tzP30ksbh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

On Fri, 13 Apr 2012 12:30:55 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> @@@ -609,10 -605,9 +612,10 @@@
>   			inst_size =3D img->sec[IWL_UCODE_SECTION_INST].len;
>   			data_size =3D img->sec[IWL_UCODE_SECTION_DATA].len;
>   		}
> - 		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->shrd->ucode_type) ||
>  -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_TYPE, priv->cur_ucode);
>  -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size);
>  -		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size);
> ++		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->ucode_type) ||
                                                                ^^^^^^^^^^
That should have been "cur_ucode", of course :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__13_Apr_2012_12_51_41_+1000_sQ7O8j1tzP30ksbh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPh5S9AAoJEECxmPOUX5FEQlYP+gM0Qi/qTJMF7dy2+egaA616
DGSPJBZy+2Frt8jZlfLZDLEoAmBZ7tHZZbo8RBBMzpb8X+LrZHIKprw/u1puzjIs
cdvSVJMG6lCmpLi6343CRCEuFFa1SNBazPZHRjOk9vC/wGT+zAydQz2DDwm4BrJU
axq61GR47lV09LGV73YX3PaVfLbnpGfLKtmuzADQHmwssa/GZ0yzh2i7A5LWfrxx
FnbsTGZTW6s/MXFTlmROjU6C6l3N4sjcp0PY3l8yWue4a/fPfRlbsaaxIcd4ps0t
KE1WdiAonAwPlBTBVU0p3uuhV53/DMycWrJSz00NfeJi9uRU8ghWIlHVZXLYvSM6
OhmLjJ8D5EMbdNGZFTpQcfYU6arG9u/bO8p/RPnaYDd0Syf2b4Ld7z7i/8uiTqCu
kHqk6LF4agaxMmFlTgC2S2Gmqb/ASA3r95MwSzg5Jwjti0E8rCcI8AauiNub9C/G
lsJJMhJnqqK1vbkTZ6vIxhkob92083MPCww7OBVYM8T7EP0sjwbnUbcWb/vad3Ks
W7KGtqgzr89IumQjb8/XRvxcquGdNG3nl2QVhDU0I4fOr+CX+8UjAZ68W86B0Hpp
oHDZbcwDzpBPibuS1p0vJqd4YBvmYmveuAKenRdTCsVa+F4WyY4KAZaZMGs1TLWn
FALyPO+VbUPtRyPdGHK5
=rC4Y
-----END PGP SIGNATURE-----

--Signature=_Fri__13_Apr_2012_12_51_41_+1000_sQ7O8j1tzP30ksbh--
