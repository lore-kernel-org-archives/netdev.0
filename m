From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 11:06:16 +0200
Message-ID: <1144919176.4187.44.camel@localhost>
References: <20060411085805.949313000@sipsolutions.net>
	 <20060411085841.252064000@sipsolutions.net>
	 <20060413020010.2ab16d7b.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/u+2f1/JmrpVn27AzGn7"
Cc: netdev@vger.kernel.org, linville@tuxdriver.com,
	softmac-dev@sipsolutions.net, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:33482 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751220AbWDMJGX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:06:23 -0400
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20060413020010.2ab16d7b.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/u+2f1/JmrpVn27AzGn7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-04-13 at 02:00 -0700, Pete Zaitcev wrote:

> This sounds completely wrong. Do you guys remember the Subject: string
> of this discussion by any chance?

Discussed offline at the wireless summit, sorry.

> It's very likely that tools do indeed loop when they see EAGAIN, but
> this is a workaround, not the main mode of operation. It seems obvious
> to me that the get method should wait until the scan results are
> available. Perhaps the discussion had a specific scenario where
> EAGAIN would make sense, but I cannot imagine what it might be.

Right, they do loop, but they don't have a method to indicate
completion. Thus we'd have to actually wait for the completion in the
kernel. Jean, what is the intended use here?

johannes

--=-/u+2f1/JmrpVn27AzGn7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARD4UhqVg1VMiehFYAQKUFBAAk2eMOc7ItoXFygQQqwvXubbPlL6gynTt
crc/b6QrsG6IaF8lJVtSZNZWZhvcnhdOqPLWsDkmW1NPRqIr3YW8dnqQgxqtheHZ
72e+x4l0cQ9SQPDHi+3kWQ6NLyBWjpiVgzRiKyyUkfyAfOSFJWLBAAXCNB7dOVJn
bjlas04sDAxU6blmNWDn489Zesf4+T9I0k2MLKzkX8S8dyjJySazpTvrI2UPEWWJ
eN6AxdjqKCKT5RRD/KNCxnfO7AIesYgB9WK0YawT8PAt+srxVQgMKU/oBQfh2Ggs
7OkLDWJFuKrGaRWQJA31CRK3cOKGtIWFHQCCQkO+ZM2nuPhMKYAuaX9CmX2H7WIH
bliStTvCp1sYi9b8eGfRekWDF2c1Ulwzc5D7WUjfVFdJLVquBsdebNs5sldVWduN
wnQmPbe+OkzeFABsDuOkkI4MAxZ5NLPJwd33kDo2BSnADksOivOkC53lSJHqBW64
wXf7L3KqlppQk7XzUknn8nt0vG37qlofq2UNylM/T+Y2aeozVCUx8/Sg3W+s+zy5
6qtRy4TMImqbcWXALph/MG+q+LTdY0yVhgxzpoxADPfQB93l2ANkWKIO7CWv07LC
4KCkI5qnaZBv/uZc8phx+HM0zMtJX6n5NKzvv73x0vXtuq/GPbJiwH1alR+5v+0k
+qKhoMlpfio=
=JAXh
-----END PGP SIGNATURE-----

--=-/u+2f1/JmrpVn27AzGn7--

