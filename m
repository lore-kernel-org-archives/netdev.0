From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 19:37:12 +0000
Message-ID: <EE75D5F9-7243-4DE0-94FE-F6279939C231@netapp.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <20160614171528.GA14276@outlook.office365.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_13BB209D-7F31-4D5F-A9E6-68C1670E803D";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	"Honda, Michio" <michio@netapp.com>
To: Andrey Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:21716 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbcFNThP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 15:37:15 -0400
In-Reply-To: <20160614171528.GA14276@outlook.office365.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_13BB209D-7F31-4D5F-A9E6-68C1670E803D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

On 2016-06-14, at 19:15, Andrey Vagin <avagin@virtuozzo.com> wrote:
> Recently we found that we have to restore more parameters for tcp
> sockets.
> https://patchwork.kernel.org/patch/9144995/

thanks for the pointer.

> As for your problem, criu saves and restores mss_clamp. Could you =
check
> that it works for your case?

I do this already, but clamping doesn't help here, since it only limits =
the MSS (but does not increase it from the minimum.)

Lars

--Apple-Mail=_13BB209D-7F31-4D5F-A9E6-68C1670E803D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXYFzpAAoJEFS1wwm/cMFXB0AP/1/OsaoBMVXGnzb1CT316ije
jp1DA26IgZGZ9dQ4AZzZW5WQvJsAbdTSHgIertbBneJ6B1VeA0E7xzqE2s7TMsjT
UL54gXPJ+1ZS6GDjbX/CagQtYfO/injCuoIp0f1bbWghiCQ6eVrFdTx9t3Uk/y6J
mV+KUVZ7eIxDKvpG71KHuPzTVgAIVekyzGKfR7u4Lc/FW7DR/x7l/JdHTXVbr8Jv
yrC8btHJrMRhL2Ne5Kwn2zz/nCTAEUBMWSIkIsOqn6/JhJMfLqM3cxSqJHH/iNry
LVsDheBhhLoGPq3uWlLSctnQKz7NhEKRKEEUQkIQ38BsUdGVS/4JzaMK1pSGw5Tb
D/2nfR/gc3nzgQGi8xPUOjEPUQ+t61Hh+hozsIwZP77gS6L1t1xTlZTTJlKMSmuW
2tkhVgzdIbPb9iZCOSIQJTeN7kjPoUpeZWZJTBfRIOoxGrrf9Q8wqW172MNQN/TT
tJYlQaJ3P1KsrSOtsBHOwGxzLxy/uloQsRf4sMwmea8ReZLmYq1Gx0UWjdvdeWsc
NDxIL1z5gwitP0LzoyD7RgO47FVwLcV8obAwynHIRsb4bTjRVbN6lq4nYGsQ+bvE
0w/9n4XkT3/iYG/yQ57074EE+rbwswMF+JW8+k3dSQ8CaBjrJTJsQQxkvQOtsCSi
LZuw/2pFBqkVlNunRs5+
=fgtj
-----END PGP SIGNATURE-----

--Apple-Mail=_13BB209D-7F31-4D5F-A9E6-68C1670E803D--
