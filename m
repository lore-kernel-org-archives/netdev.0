From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 11:34:50 +0200
Message-ID: <1144920890.4187.50.camel@localhost>
References: <20060411085805.949313000@sipsolutions.net>
	 <20060411085841.252064000@sipsolutions.net>
	 <20060413020010.2ab16d7b.zaitcev@redhat.com>
	 <1144919176.4187.44.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CRHPLlofe/Q27ikpiF6v"
Cc: Jean Tourrilhes <jt@hpl.hp.com>, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:161 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964861AbWDMJhQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:37:16 -0400
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <1144919176.4187.44.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CRHPLlofe/Q27ikpiF6v
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-04-13 at 11:06 +0200, Johannes Berg wrote:

> > It's very likely that tools do indeed loop when they see EAGAIN, but
> > this is a workaround, not the main mode of operation. It seems obvious
> > to me that the get method should wait until the scan results are
> > available. Perhaps the discussion had a specific scenario where
> > EAGAIN would make sense, but I cannot imagine what it might be.
>=20
> Right, they do loop, but they don't have a method to indicate
> completion. Thus we'd have to actually wait for the completion in the
> kernel. Jean, what is the intended use here?

Hah, never mind, I guess we're just supposed to send SIOCGIWSCAN. Will
send a patch in a minute.

johannes

--=-CRHPLlofe/Q27ikpiF6v
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARD4bOaVg1VMiehFYAQLbghAAkaAcM0H+BogTcC9sAQ+QpK7wn/RPLi4D
qoSHyxE1TDbjPJ6SEeqv/YGc3+/AI9eAsIzRnq/vG3h7+/bTULzWN1mBYZ6/P6mh
FZpmn5JFkhttW0MTOKO+uIbYOxdZVAx0q/eck9E+1vJZZgFwdDwiHAD0fXS2cZRk
abMURbBYHdPfKikJT5ZvANqe0EigU38hVM0vFt3PCN+FPXn7u4edNOQQEDrQ18Fe
7ZGfKGh+sXYgKQ9O0JI+jfSjCig9R5ZVkX94y4kFYf0aNzvLZF5LVEfAVUiwh27w
iOcFKDSLBH/sKsqOQ7R8E4wIgitEkCcH+BDuSRgQAFFOYB8++UGY1q/JqN8xmjFh
Y9EpNeEuWjLgKFYEyYhKn1NlVkbu3OsGGioZNzlK6L6I3UcOs9q2QDF3E0NGLEDY
WBwahpvr/ETI2RT/LmeNFMAh/uuVJ1BG6YY2hmAjhttZXcz46GFQ65y9LNilpSPb
THTMHMMFODVQIMBsunYRuWGMAfcHNm0zYh78+/jIdEGPIRSLBYLZh6p5B3wnvHtz
Q0tAIGeGXAc+sC6N84NQySVnxcEnnfm9TCb7ytKxlKwzL79Hrw736KzawG0tQb+b
wGGOarCDS2at9BZS3J94bseEu0z9kK0sunTLQGoUxlBSHKAcGv5V0yqXwwjy8Im9
2jtf62cPrLA=
=wzAE
-----END PGP SIGNATURE-----

--=-CRHPLlofe/Q27ikpiF6v--

