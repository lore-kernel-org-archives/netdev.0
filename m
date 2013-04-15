From: Ben Hutchings <ben@decadent.org.uk>
Subject: [stable] net: sctp: sctp_auth_key_put: use kzfree instead of kfree
Date: Mon, 15 Apr 2013 01:03:00 +0100
Message-ID: <1365984180.2783.86.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gaC1GhMe3xdbDlLjVdd+"
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Brad Spengler <spender@grsecurity.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46399 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752130Ab3DOADM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 20:03:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gaC1GhMe3xdbDlLjVdd+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

You sent these fixes for potential key material leaks to stable:

commit 6ba542a291a5e558603ac51cda9bded347ce7627
Author: Daniel Borkmann <dborkman@redhat.com>
Date:   Fri Feb 8 03:04:34 2013 +0000

    net: sctp: sctp_setsockopt_auth_key: use kzfree instead of kfree

commit b5c37fe6e24eec194bb29d22fdd55d73bcc709bf
Author: Daniel Borkmann <dborkman@redhat.com>
Date:   Fri Feb 8 03:04:35 2013 +0000

    net: sctp: sctp_endpoint_free: zero out secret key data

Brad Spengler pointed out there was one missing, which seems to be this
one:

commit 586c31f3bf04c290dc0a0de7fc91d20aa9a5ee53
Author: Daniel Borkmann <dborkman@redhat.com>
Date:   Thu Feb 7 00:55:37 2013 +0000

    net: sctp: sctp_auth_key_put: use kzfree instead of kfree

I assume that was an accidental omission, in which case please include
it the next batch.

Ben.

--=20
Ben Hutchings
The first rule of tautology club is the first rule of tautology club.

--=-gaC1GhMe3xdbDlLjVdd+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUWtDtOe/yOyVhhEJAQq+5xAAhzX2Sc/gTQUCssD257veCv3WAFYyki4S
yLmh6xZHZV/5QlB02e7zZ9asoGkh1O/+Slt3te9THGD3ZiBghh1KPue17w25Nezl
3eZNC5Z3Gv1SMghSum2GgT40ChvI9TxdlLGiY9z2BmEuodXsAscvVcwXM612A0O8
O97grIVHXEbRaiZ86wjw2Kp/YWYngnrdsp4R3LsY4hAU5epmE1HF1RE/8QQCG9H/
r7xl7IvBvvNVlSEnnR3UmBPBHLzXLuHE16NnFwJRmzI0Or0N5XYqDfSUMxeZgpye
TClWzdW5mVYLF9+QEYEanHDJ347FHdjzS7cadv/phQ2SCl/M+nSaVpPruUkEkRAj
sB8MGqkFyFT/QSSI9PMQG4ouZg4wvyIpcbBMRkBsodNpqou8MuIcvXBGJ/E9vDxt
Te9DmFvv/9jVcGDkAzPEDBuJziuVepKfaKD23NnJ5li1ff+CfNvVixvbeCB82zzz
naoKV9/vxsdNNEAhe2wWhAQsWZNbfQvmtAKFt4trHofP7Hmvpxo+JZzXXnQ8M1ln
G4nEA0VIGLuMf2FuIYSZQ2yLHCHaqjDBlO9XvfXWDXFUpdYq+clUwGUXCG0Ytwd1
K3cxNw51FXliHh/Wl4M6XM1qI/kgq6vymj4l+wunl+Oy9JtTjzPHlfDqiIZXdunN
CUQTFDmsJz4=
=itod
-----END PGP SIGNATURE-----

--=-gaC1GhMe3xdbDlLjVdd+--
