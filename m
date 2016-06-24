From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v10 07/22] IB/hns: Add event queue support
Date: Fri, 24 Jun 2016 11:56:08 -0400
Message-ID: <7e1062ac-eabc-34ab-dd76-c8eb6b992307@redhat.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-8-git-send-email-oulijun@huawei.com>
 <20160624154643.GG23995@leon.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xjbJiCkDKqqpJjd14JDlGKIuwcLvI5xn4"
Cc: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160624154643.GG23995-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xjbJiCkDKqqpJjd14JDlGKIuwcLvI5xn4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 06/24/2016 11:46 AM, Leon Romanovsky wrote:
> On Thu, Jun 16, 2016 at 10:35:15PM +0800, Lijun Ou wrote:

>>  /*************ROCEE_REG DEFINITION****************/
>>  #define ROCEE_VENDOR_ID_REG			0x0
>> @@ -44,8 +93,29 @@
>>  #define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
>>  #define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
>> =20
>> +#define ROCEE_CAEP_AEQE_CONS_IDX_REG		0x3AC
>> +#define ROCEE_CAEP_CEQC_CONS_IDX_0_REG		0x3BC
>> +
>> +#define ROCEE_ECC_UCERR_ALM1_REG		0xB38
>> +#define ROCEE_ECC_UCERR_ALM2_REG		0xB3C
>> +#define ROCEE_ECC_CERR_ALM1_REG			0xB44
>> +#define ROCEE_ECC_CERR_ALM2_REG			0xB48
>> +
>>  #define ROCEE_ACK_DELAY_REG			0x14
>> =20
>> +#define ROCEE_CAEP_CE_INTERVAL_CFG_REG		0x190
>> +#define ROCEE_CAEP_CE_BURST_NUM_CFG_REG		0x194
>> +
>>  #define ROCEE_MB1_REG				0x210
>> =20
>> +#define ROCEE_CAEP_AEQC_AEQE_SHIFT_REG		0x3A0
>> +#define ROCEE_CAEP_CEQC_SHIFT_0_REG		0x3B0
>> +#define ROCEE_CAEP_CE_IRQ_MASK_0_REG		0x3C0
>> +#define ROCEE_CAEP_CEQ_ALM_OVF_0_REG		0x3C4
>> +#define ROCEE_CAEP_AE_MASK_REG			0x6C8
>> +#define ROCEE_CAEP_AE_ST_REG			0x6CC
>> +
>> +#define ROCEE_ECC_UCERR_ALM0_REG		0xB34
>> +#define ROCEE_ECC_CERR_ALM0_REG			0xB40
>=20
> Indentation

I'm pretty sure this indentation is fine.  When looking at patch file
contents, the beginning of the line is shifted one char to the right, so
when using tabs for indents, if the line would normally end at the final
char before the next tab, and it gets shifted one char by the patch
format, the contents on the other side of the indent get jumped an extra
tab spot.  You would have to look at it as a file to know for sure, but
I'm betting you can ignore all of these indent issues.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--xjbJiCkDKqqpJjd14JDlGKIuwcLvI5xn4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXbVgYAAoJELgmozMOVy/d65sP/jBB+qVM4uaqCDmJnl3ICYb+
viXyhfh4lLHrmHY0MU7ZgdVCEQvIn1JWa1rKYe9QIvdRPmzgvV4osR91p3mULrVO
LZD8ukeW+UDacLF7N3jjU9RrHyl/pd2rKF0t/kHckxbw33Xbl0dNO8OSngZ6xFLF
P3fvxysyvGg8Fj1tKSDZI/zVKknsOHJpahwpiUaZ5pjtkKSXbTgjMTzgk4uU711V
yRGq1UOme47Cx1GX1y9+Sq6VVSWSR80ujzfFd+8xo9Izzbpb9aDBIF4t50hkmJkd
iswJINI3l1US4bZPgl6eRxD7J8bP92EShvHIfUgIjE69U/kppGcyP0xc/YNG/LJZ
gaOyVquXQVXjOUx1l1NVOgo51qpr2deGfJAepcznEdVIX9wlq8/r3nMlg8ARFYQB
DPMxUjIkspdk3/j+pdWJPMjCKbF1uXPMV6fsBCgpuKD2YNFFVGVZipbvAUXQrO/3
AkWNKMtQZ12u0JEmWecrAxM3Rek+Hlpdv2sffk3pD8EJEzzVJ2D558Zk1V1Wa4DX
pK36EZB2dC3H3gW6rYoryKX1jwrx43GwvW4TcZ5pVYh31QOWgi1g1MJXAXiXdy6V
b3WJehRWz0/z4lpc9YrE9P4NmxZUDSNbX4NBhd1h7W/PImvNJxLqYTld7FkbD7sv
X+stoGRPboCV4jfJeoZ8
=kgu/
-----END PGP SIGNATURE-----

--xjbJiCkDKqqpJjd14JDlGKIuwcLvI5xn4--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
