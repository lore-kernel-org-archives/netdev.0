From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Fri, 06 Nov 2009 09:55:52 +0100
Message-ID: <1257497752.29454.11.camel@johannes.local>
References: <1254473048.3959.76.camel@johannes.local>
	 <20091105.210806.40981707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-jWA1qLN2VAuIZEIT8OxW"
Cc: netdev@vger.kernel.org, j@w1.fi, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46481 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbZKFIzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 03:55:52 -0500
In-Reply-To: <20091105.210806.40981707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jWA1qLN2VAuIZEIT8OxW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-11-05 at 21:08 -0800, David Miller wrote:

> > When we want to keep track of resources associated with applications, w=
e
> > need to know when an app is going away. Add a notification function to
> > netlink that tells us that, and also hook it up to generic netlink so
> > generic netlink can notify the families. Due to the way generic netlink
> > works though, we need to notify all families and they have to sort out
> > whatever resources some commands associated with the socket themselves.

> No fundamental objections.

:)

> However, as a followup, netlink_kernel_create() is becomming
> function_that_takes_too_many_arguments().
>=20
> At this point it's better to just pass two arguments, the network
> namespace pointer, and a pointer to a "const struct netlink_kern_info"
> that holds the rest of the parameters.
>=20
> Could you make that change too?

Yeah, I agree -- will change.

johannes

--=-jWA1qLN2VAuIZEIT8OxW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK8+STAAoJEODzc/N7+QmamtwQAKWuF6aeMMzfvQmIQNi1QSb0
qI1rpsmG/zbXT4Ep8iax9GmykvYJ7Yeoxw4wqaoouK2yMjWdWoRvyEZA9kMvj96+
PoEfN/4vOrLUG8yTFI35M4BxX8Qb5khcgfdVPZF1b6X7UgYr1VYP2LjzXEtL0rO0
LIP+A8Bq+UzuOmqEZGZQCORHfhiAvEcxgNDhrFLlT65faVhw2rRHg3MByjn+RWNm
FgWosKgczFTiWHGNHdQ3Xlx4PNV/nikx0/CImOQWGUgbvf+5Kfma4X0AEW7pPqah
jAm48TdwTn0l6PzYB40KO0vNlmQMfdB4UaFD9yIjAw6w1WZ2yHRcNQTazD0Taha+
Aa/vMlmwz5RMpEt39MIKoTZM/X0Ut0J4HuVpjRsAjkROeL/Rn8X+/Kpj74OwDv8F
NhvYRq9goKY73RfbmYdodDBnnfBtC+7+P575xByXpPG49Dp8AIsAu194QV0nT3AE
li3+Df+QqJJ0nBEe7jlma2Zi+f+HxHhzSnz/bAm55hCWPYCuVMwz6VMdVujF8Yas
pIN74IXYjKOwYxiI+qOKhPAKuAVdJBvrcfOiQMPBQAWsDDbnT/9k33iBr3UToID5
hPn3k38ubdqRrB77h7GsfCJCofWZlKMSEJcmK9JK0jMJcoTfA1KnHgwUbZEmRGX4
t65q+El4ylUcqhEeF3Ck
=KyHY
-----END PGP SIGNATURE-----

--=-jWA1qLN2VAuIZEIT8OxW--

