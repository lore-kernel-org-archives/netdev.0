From: Sven Eckelmann <sven@open-mesh.com>
Subject: Re: [PATCH] bridge: Add missing include for in6_addr
Date: Thu, 18 Apr 2013 13:04:28 +0200
Message-ID: <1628913.yHk1cpqU9i@bentobox>
References: <1366276658-11938-1-git-send-email-sven@open-mesh.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1701743.WLD7NemtCg";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht2.myhostedexchange.com ([69.50.2.38]:1492 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966748Ab3DRLEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 07:04:35 -0400
In-Reply-To: <1366276658-11938-1-git-send-email-sven@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1701743.WLD7NemtCg
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Thursday 18 April 2013 02:17:38 Sven Eckelmann wrote:
> ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 ("bridge: export multicast database
> via netlink") added "struct br_mdb_entry" which includes an element using
> the type "struct in6_addr". The file linux/if_bridge.h is part of the uapi
> and not defining this type in this file or its includes causes build
> failures in userspace applications.

It seems this one was already dropped [1]. So, I think it will not be 
different this time.

Just ignore it.

Kind regards,
	Sven

[1] http://lkml.indiana.edu/hypermail/linux/kernel/1301.1/03024.html

--nextPart1701743.WLD7NemtCg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJRb9M8AAoJEF2HCgfBJntGwe4P+wTouLWe60EmLX/eUBFZFW1p
hTP3yg4OKEK/AAudREouhFnmvts/rulzUmaK9oq+t4PyWVlBvvMgu4SfGbYtFZv0
7O9dQslFR70V6619JEBsOXGRJaxTxnNKgg9eGTtJk0UGmat42ZEj7un/j9FCCD5K
a6t5dmgE29FZGY+eyC3C5QcY3MToW/e2qWFH+IZZO/21ugOUDwfe1xMHkTL+0aPx
degFo1u7VT/kMzBiBU93UpktPW3MkVZRS/6RBB5CfSse0phi00uVYdC3RICun365
XtoSTdOKXvWffHFGBYOkI6GN0som9Zr/EsBlKqY9rxb7uHCF9rQpjuIX0MTft+1y
RRSljtlAllZU0M847kEv2fVM5H9H6tjURMuzSH32UMAbMVUSBWVjiT3sW7C2oSW5
5uqrQQj9OJi8m3dSxT1OjWqq1FwLmH3d6dcajU9YmgZyOZQKSJ+KQBqtT6BeIjxD
Ho0XRv2GS+xGWIRySMTIf++/CucdkhfynbnQdkHUYYDAwkcfoSJOKmITBvqSGNtQ
YydCtiwbZjEzCT3Q2AvmvqGMIRSQ+8YLLMw/L+3+N+s0d6wuJ+WR2IXxm4TRy2EE
sEGYwwzP4/f58DhEqViTS6QS5T5bJleue4b7CiGuQx10spuZGtTQMlmn+OjiTZzV
27Vznnt87w5ya4tQd92w
=CyGM
-----END PGP SIGNATURE-----

--nextPart1701743.WLD7NemtCg--
