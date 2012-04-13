From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Fri, 13 Apr 2012 12:49:21 +1000
Message-ID: <20120413124921.971328c46e234f39eb2e20ff@canb.auug.org.au>
References: <20120413124103.5bc632a6425ea9da9c5c4aae@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__13_Apr_2012_12_49_21_+1000_pSRLmpSeRdSmaqLH"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Samuel Ortiz <sameo@linux.intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120413124103.5bc632a6425ea9da9c5c4aae@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__13_Apr_2012_12_49_21_+1000_pSRLmpSeRdSmaqLH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

On Fri, 13 Apr 2012 12:41:03 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
> index 539d041..24d8d12 100644
> --- a/net/nfc/netlink.c
> +++ b/net/nfc/netlink.c
> @@ -202,8 +202,10 @@ int nfc_genl_target_lost(struct nfc_dev *dev, u32 ta=
rget_idx)
>  	if (!hdr)
>  		goto free_msg;
> =20
> -	NLA_PUT_STRING(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev));
> -	NLA_PUT_U32(msg, NFC_ATTR_TARGET_INDEX, target_idx);
> +	if (nla_put_string(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev)))
> +		goto nla_put_failure;
> +	if (nla_put_u32((msg, NFC_ATTR_TARGET_INDEX, target_idx))
                       ^
I removed this extra parenthesis. :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__13_Apr_2012_12_49_21_+1000_pSRLmpSeRdSmaqLH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPh5QxAAoJEECxmPOUX5FEyfYQAJIUXXNcNq2KM4HJyaQ5FhHg
aUcvIYXxXVoW2VEWqe0WYNh/8Qw+0WoMxgJHOQtLxPZ8AiEeja5p3mqGXwMXDpZb
79rPR0L5f32iJNJYS/cjajaiNxd/glL+RUmM/rfuhrKvfAqwjdoNca2N+t4Wh68O
zkiknr7UtjbfugMnUA8O5GgZsz/G53VmFCseQyEt21HntIfPPYvDI+MGQ3dqqPfc
TQvwLycrnwpfyytz4iePMN4Ud+2uywxBCQj8SZP5RgOrMsaYKRixKgl4UNuWRmAq
c2e2BIG1NCoVNrJKX9qk+Krypex7GuSZf0ps1D6Q+IH0hBVHJzqfSXx4TDcwmXSd
e72aX4YLRAUAj9bcphCF+wlGvEjqITvYJK+UNq6CTpcgrcCPzZAnRriyGafvCHB9
J9XwYH93K1iQIk2zDcCh7FBWkCFoiHqvVUrnOWvkvG4wKfiEpNDr5/uCp3qdIYuy
8jkew+srGLwzXeex0LpAhWITUkFxbq/RW8BIOooWW7aTC4ARfZ8JPJh7NO2WZJBe
9FRcGJrJ8grlHP182R2u+O2PnmThZdtdn90GAg/yU/wd2Cy54joxOnKnAbIwHzNo
1dNxsclTNz4lTHIlCjKYE16okr+2SL8cXFRGvJX3zczSnOsM1lNHp06fCFDcE4kY
G4LTUzRPW8kyLEyKW16O
=adrs
-----END PGP SIGNATURE-----

--Signature=_Fri__13_Apr_2012_12_49_21_+1000_pSRLmpSeRdSmaqLH--
