From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Thu, 16 Jun 2016 07:51:22 +0000
Message-ID: <5A6E3EFB-2B69-4C3C-BC67-CAFEC5B2DB2C@netapp.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <20160614171528.GA14276@outlook.office365.com>
 <EE75D5F9-7243-4DE0-94FE-F6279939C231@netapp.com>
 <20160614205741.GB20722@outlook.office365.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D01E96D8-714C-42AA-93A1-C4740EC31081";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	"Honda, Michio" <michio@netapp.com>
To: Andrey Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:14525 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbcFPHvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 03:51:25 -0400
In-Reply-To: <20160614205741.GB20722@outlook.office365.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_D01E96D8-714C-42AA-93A1-C4740EC31081
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

On 2016-06-14, at 23:21, Andrey Vagin <avagin@virtuozzo.com> wrote:
> On my host, I see that dst is set in tcp_v4_connect() -> =
sk_setup_caps()

sorry, are you saying that you don't see the issue with =
TCP_MSS_DEFAULT-sized segments after TCP_REPAIR on your kernel? Or are =
you saying my quick attempt at analyzing the cause was wrong?

Thanks,
Lars

--Apple-Mail=_D01E96D8-714C-42AA-93A1-C4740EC31081
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXYlp7AAoJEFS1wwm/cMFXpFMP/0irPUuBKogHIXX02LP88epP
9QLI+onx61fmNoFJNyKt2v31iTtYd93AnPWhgxLz5BsmAjSk5PXqipa66Q/6QVeg
leIpUhLwTABf3GONMCsC5y4wsfgw3Lnh32vm4ijw+CSBtTF07Rao6j1jQa0GLGYj
EcvB2CHW8sfwDldmwG/E4XabqDUcwFqqvRdY3S+A5Gm382L+zWVBuBZyk+HUGJ+1
dDz/ewvxizyKbGfinbW5D+1ldfKX/EBRPo8bnNbPAbiPdNL8HRHzPxJByqfdhZ24
KiUyC1f9U5lSLzPVbgKcsHdUxAPgQQ+/4Kv4UVclFJVOyqG4aGPvx4UYOjMM7tpn
H7pLq9IOcm9ZZsj1vglXXjxuBsYRD0zfkTffSfTKbqzCbBJxb+OKOZfJORF2H1on
UgZE1Ho1lQMs4yiV7GR1PuwarbSFJ1sL60ND/ic0XC8U03Rl66886gnR4pLgsbKe
aVnJRwd/4oxdeuZWJV9sGNxuWbAufKoLHeGNbZiBRKiB4dxfcUd0JRCiR0M12iMp
UN2uLbG3oKTAnG5i1z25/1cRWMkSGU+7upRt6r4E0gf8njKhK1rDNYPGgyZFPlU2
zBTmMFpB3Lj9GYYshd47HM6dYetkHfKEuLvVgl2ncjzPykhv9ijfqW6wXmBhOn1f
s5TIpDW+sVX4XjZzsFhf
=9/Kb
-----END PGP SIGNATURE-----

--Apple-Mail=_D01E96D8-714C-42AA-93A1-C4740EC31081--
