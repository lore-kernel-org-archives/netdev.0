From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] i40e: Change some init flow for the client
Date: Wed, 24 Aug 2016 17:53:48 -0700
Message-ID: <1472086428.2527.1.camel@intel.com>
References: <1472086313-121437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-qQrlKKAeUtvHV2pACcmL"
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30344 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757311AbcHYFYK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 01:24:10 -0400
In-Reply-To: <1472086313-121437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qQrlKKAeUtvHV2pACcmL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-08-24 at 17:51 -0700, Jeff Kirsher wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>=20
> This change makes a common flow for Client instance open during init
> and reset path. The Client subtask can handle both the cases instead of
> making a separate notify_client_of_open call.
> Also it may fix a bug during reset where the service task was leaking
> some memory and causing issues.
>=20
> Change-Id: I7232a32fd52b82e863abb54266fa83122f80a0cd
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_client.c | 41 ++++++++++++++++=
++++-
> ------
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c=C2=A0=C2=A0 |=C2=A0 1 -
> =C2=A02 files changed, 30 insertions(+), 12 deletions(-)

While the original patch description did not call this out clearly, this
patch fixes an issue with the RDMA/iWARP driver i40iw, which would randomly
crash or hang without these changes.
--=-qQrlKKAeUtvHV2pACcmL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXvkGdAAoJEOVv75VaS+3OaBQP/jk4Jw+RCNtzsZEg4N8eBDXM
vmHdvjNW5PpAoROdRl9o5RemmnVMD+0RapsKLDG+ZrmQgbLLf2FoKF5GHGrzaFzN
cLSrDmi7bFL7vv0B5y6tbrRsqrWi7VcCGPq5utapIC3Bk7J6Z4tgGL8MBaKDl7Gj
/vFguggyhxGU2Kz2TQxhmTc1fIvvoLAOXloowYY3Um4+BuG+nsay+VNuciBAfQoq
kJk2bRNX7quyf4Wr8tzWjtet8lOMa79X1D0gEUxKI88ZBU8CByQcGBpb1gQsTf9g
dVJOV3s9FkBp2EttpMZc3RqmacMm/HxaiwLN6xKsIAskLw9rH0204JjdK3REU7lP
XKQjtwFEF8dF+VJyrtElPIbk8fMdGU54YY3m9xWrhdJ6U25s0nzqzkJeUcN+kFZc
Jyt8HU7DXdUF2L0qm/QSv17Ku1SeSUgoVRnEFsdyUmlDEM3x9qj+Fwy5IJ7YtL2i
tnNGGdo9Xp2x4ay9oysMDGw0rHIgMGb1KR67ma4EYcMzi1B/pgQdeO16+zuWzonI
h0UgIxDZAuRI9gw7BqR0CB2dzagAeOepy11sGgdX39FYUWQClIyqyrYHwalCmYSn
SGn4mU70cJUNhAahvAMYvYrYC8mov38WMhM7ypG1k7y2A1qv+hhVbicj+8s2YasS
7jpgZ2NlZX/+I2BS+Zh4
=4HDf
-----END PGP SIGNATURE-----

--=-qQrlKKAeUtvHV2pACcmL--
