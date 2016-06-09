From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 09/22] IB/hns: Add hca support
Date: Thu, 9 Jun 2016 10:10:14 +0300
Message-ID: <20160609071014.GR3663@leon.nu>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-10-git-send-email-oulijun@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4NNqsQ/a67jpuySk"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1464795484-77395-10-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--4NNqsQ/a67jpuySk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 01, 2016 at 11:37:51PM +0800, Lijun Ou wrote:
> This patch mainly setup hca for RoCE. It will do a series of
> initial works, as follows:
>     1. init uar table, allocate uar resource
>     2. init pd table
>     3. init cq table
>     4. init mr table
>     5. init qp table
>=20
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---

<...>

> +
> +	ret =3D hns_roce_bitmap_init(&cq_table->bitmap, hr_dev->caps.num_cqs,
> +				   hr_dev->caps.num_cqs - 1,
> +				   hr_dev->caps.reserved_cqs, 0);
> +	if (ret)
> +		return ret;
> +
> +	return 0;

You can return directly ret, instead last 4 lines.

> +}
> +

--4NNqsQ/a67jpuySk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXWRZWAAoJEORje4g2clinNc4P/3Y4W91zCrYR7O0KTWUezW3B
NVlwX0Ow0qpFdgqANW+Rx3YqrbuF12oFwNkBEajP0eGlpkdZN2oUqHPu0eA7mV80
TeDQWeGjtrJHjB9fYSBGn8cTG8d+cO3jHzW1HwYbdtEy9+qesnibKmemkCHuJdSA
ZNufLVvLSTPwNaq3DBg4RzFnMPFF6f8GoJxX/dn2P0DQScSN1qZJuyZ1/EVkRIRV
+Eh1fywiHHCU6+FplbbpHHE/x+Hx+HFGMRPi/78ilu2vttdUC6Wjbbgr00dfHMi+
aXferVP7upjI8+iRDVb8pBErEqJAUCMFvwregBX4AX5gQrcOjU+/sDBMwMiD5b+U
F68yI8R/NfBA8P6lfiZfJ7J9Wy3I1g6/1Uikl0nseQRPaqnYeAFfmf6pByXMdktL
W+55mV56TXn3nKQrD72rqajfw0k+X+66BboWlWFFTcGOatxoQPBf+7Cm4ztqDA+i
IQGiTTt6BD6YMeJgmMi4PhqZtrSmX1iN7i3u7ENkWpv3DwiqZDy1+AboE8hdfv8G
/b73s46eDkTECZf6iYNdZm1/KwSNnpQSpciFBJO2fJU4LuskgEyTmXmhlVvLIlpv
xgvEML2jSnuSAOE2OhHB+UYpT+T/ggQsk2EmteJmyETf8L0M7CCvnlnUX3jhKlqG
zd8xfZcN4uGu6ajV6/wO
=ov7W
-----END PGP SIGNATURE-----

--4NNqsQ/a67jpuySk--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
