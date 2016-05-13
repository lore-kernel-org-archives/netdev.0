From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v7 07/21] IB/hns: Add event queue support
Date: Fri, 13 May 2016 17:21:45 -0400
Message-ID: <95521a53-03df-7768-62dc-018b28528296@redhat.com>
References: <1462849483-67927-1-git-send-email-oulijun@huawei.com>
 <1462849483-67927-8-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="6rdPbVc1LueFLPWUu8w3RjQ6bftLcUgpf"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462849483-67927-8-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6rdPbVc1LueFLPWUu8w3RjQ6bftLcUgpf
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/09/2016 11:04 PM, Lijun Ou wrote:

> --- a/drivers/infiniband/hw/hns/hns_roce_device.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h

> @@ -29,10 +31,93 @@
>  #define HNS_ROCE_AEQE_VEC_NUM			1
>  #define HNS_ROCE_AEQE_OF_VEC_NUM		1
> =20
> +#define ADDR_SHIFT_12				12
>  #define ADDR_SHIFT_32				32
> +#define ADDR_SHIFT_44				44

I saw some of the early review requests to replace hard coded values
with defines so that things made more sense.  And you've done a lot of
that quite well.  However, this one is not so helpful.  Sure, it's an
address shift, but the define gives no context as to why these shifts
are what they are.  Someone from the x86 world might mistakenly think
the 12 shift is all about page size shifting, but on arm you have
multiple different page sizes and 12 may not work at all.  So, some
context in the name for these items, or else a comment above these
defines letting us know what's special about these three shift values
would be helpful.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--6rdPbVc1LueFLPWUu8w3RjQ6bftLcUgpf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNkVqAAoJELgmozMOVy/dAbgP/0f2iRlfCzPKnW9QOT/Co16M
crs/HAVf22QOTDheAAa4OmJfpVYW/GkCgPQh7LnZL3e7kcVFinx5tDSUcYPuD0h0
nCDZXD0ZFHd9vpmDBbEMXOyivTuDNuw8RgfJYkmfOIIJlBQB78aGRmdHSXHWqjnH
W7BKDRZAgMnKKCsHJPDnKO444ZqOktEyZM3IyJW3rgMV800ssf6JTjIhyR7PFpZc
wv5P0zbpFQbqmrBDaI+mTx8aU1ZaKqW4RuYuG2ZZdWYp+9B2bSA9ISceJnc/74KF
SaVlOVhL+DKklyZB98PJs80i2mAkUXvaryP9tMvFM0EqeFKCZgrjKfjlYIKQ4gzX
yjS8qco90+w3W8b2g4vCToD58tWWFqoeFrrFEOjKlQxO4BIU4vojWBy9r/0+FmjU
BLhYmBBYZGfjTzrqMZZJE55l8oQRGk0u8I4815UCepIBaNMyz3RFWNATbvf7uFA0
Hl8UhjGuGkdP2iTYHwwO7QeVPJeDEz1xhcm8PcFmIHOWDkJxqtNfAMB6rtw1phMB
h4qTcqez0wa1X5H07EB3gt9Sycrp+rG4pmAelpZtuc4GUbvZCqdwtLwatmezWYgY
5V2BRt9umC95E2rUKrgNAFBKUErdkiTOOTPs6W0gw5L6EwLcSG1amfCBXicpKonN
M/xqHrn/dYBTnUjr5BNy
=Jjwo
-----END PGP SIGNATURE-----

--6rdPbVc1LueFLPWUu8w3RjQ6bftLcUgpf--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
