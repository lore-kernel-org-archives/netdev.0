From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 1/2] igb: Fix warning
 =?UTF-8?Q?=E2=80=98pin=E2=80=99?= may be used uninitialized
Date: Thu, 05 Mar 2015 11:27:03 -0800
Message-ID: <1425583623.2556.142.camel@jtkirshe-mobl>
References: <20150305192031.22228.75375.stgit@ahduyck-vm-fedora20>
	 <20150305192459.22228.86492.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s1Pk/yULojI8wOvppLm0"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43231 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbbCET1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 14:27:05 -0500
In-Reply-To: <20150305192459.22228.86492.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s1Pk/yULojI8wOvppLm0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-05 at 11:24 -0800, Alexander Duyck wrote:
> When building the kernel using the gcc 4.8.3 compiler included in
> Fedora 20
> I was repeatedly seeing the warning:
>=20
>  drivers/net/ethernet/intel/igb/igb_ptp.c: In function
> =E2=80=98igb_ptp_feature_enable_i210=E2=80=99:
>  drivers/net/ethernet/intel/igb/igb_ptp.c:395:21: warning: =E2=80=98pin=
=E2=80=99 may
> be used uninitialized in this function
>  [-Wmaybe-uninitialized]
>    tssdp &=3D ~ts_sdp_en[pin];
>                      ^
>  drivers/net/ethernet/intel/igb/igb_ptp.c:471:6: note: =E2=80=98pin=E2=80=
=99 was
> declared here
>    int pin;
>        ^
>=20
> To resolve it I am assigning the pin a value of -1 when it is
> instantiated.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Alex, I have added your patch to my queue.

--=-s1Pk/yULojI8wOvppLm0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU+K4HAAoJEOVv75VaS+3OSg0P/R/8TwiMYvW36dFOmR65GshD
N/s3mshuzQ0SlqUWRk7ECal4Eegi+Nnxm0VOUCa6Szj3l2LAuLQTA03qceRG3our
7YZLEnrR92bBHjBlecLazAh3U0X09iIYXCjvMg0zbXiQJSIKJ1T55H1tNMll+b88
y0D0FrGmhIV/hP7KiA2+k/QqSwPQl7Pq1eU8KsdjblLlkXxEPEiLyYRHwrhLfQ6/
8iqT0rBp9BP+fvf3k+ndGDjkViFn7JInjKBLS8Km3/Gk+x1w/KVr2PmlttY3gKD9
dX+Xqaj3naCO2jo7lhBD9JJsQGPDwUH62CJCRdrjtVbSb1gBGKlpMnlZ1kqh4wbb
xrURlyvf9D0BA7Cyvfz6h2FXsXLSkMVE1XSh/ppjjy0vpZ+qokiiKdMVuYTQeFvw
78WusdkDspvDLaW3c0AQ4lBrIso9HaXWf0TKG3U3AXMlG1mqX9bl7LZx21RZmGeL
i3mg9zn9B87fafwUPF5rau1VSWYlmCFEk8XNBr1FNYFIK3q1/7gCdKiosJE4ONQq
6Czp2mFzqNRvedQYVsJLP1Bq5v44JBgHE8vqgvNRzf/5HTdcu6rSa93R7BMmTiqN
knJWGQF8RZ7U5wejmhKC0sOKiYixgnxKVjrHgCedLWip+Qnko/s4yLio/Xoy3Mhf
XxwafWHUCMfLAxn1l6gm
=GON6
-----END PGP SIGNATURE-----

--=-s1Pk/yULojI8wOvppLm0--
