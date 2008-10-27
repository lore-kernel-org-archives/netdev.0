From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCHv2] printk: add the %pM, %p4, %p6 format specifiers
Date: Mon, 27 Oct 2008 07:59:25 +0100
Message-ID: <1225090765.3746.7.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
	 <1225009822.3478.30.camel@johannes.berg>  <1225047674.10060.10.camel@brick>
	 (sfid-20081026_200122_320043_BFBB81CD)  <1225049591.3746.0.camel@johannes.berg>
	 <1225049929.10060.11.camel@brick>
	 (sfid-20081026_203902_019881_0F8064FC)  <1225050015.3746.2.camel@johannes.berg>
	 <1225060789.10060.13.camel@brick>  <1225067465.5672.1.camel@brick>
	 (sfid-20081027_013109_949949_342DF4F2)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0JnT+V8zZ9Q25vWHZbAQ"
Cc: David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39265 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbYJ0G7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 02:59:50 -0400
In-Reply-To: <1225067465.5672.1.camel@brick> (sfid-20081027_013109_949949_342DF4F2)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0JnT+V8zZ9Q25vWHZbAQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 17:31 -0700, Harvey Harrison wrote:
> Add format specifiers for printing out colon-separated bytes:
>=20
> MAC addresses (%pM):
> xx:xx:xx:xx:xx:xx
>=20
> IPv4 addresses (%p4):
> xx:xx:xx:xx

As hpa points out, the usual notation would be %d.%d.%d.%d :)

> %#pM, %#p4, %#p6 are also supported and print without the colon
> separators.

The # for ipv4 we might use for cpu-endian rather than network-endian
maybe?

Also can you keep mac/ip address patches split up so we can use my
version of the mac address patch (it's already well-tested)?

johannes

--=-0JnT+V8zZ9Q25vWHZbAQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBWbJAAoJEKVg1VMiehFYNuYP/0hrWNJAyccXLxOhAa7QjiBy
dGUwn5hIDipE8s+03avJWAq2T85EOXDAgSL+vjh6z6LS+N3YqzalrP+vsmQVjDEY
h2evusaEMJnyyPqyZxf/S7WUZ2DG5a11LkYwNJLcxUKiNLldXErwZvgzrIWwgfRV
N6prQ2pehPFe7hoyjGnzKb/+B2z3E8Hu5NytqQCf0rDLMvm8TE2E6srqapZVk1dZ
AkpA2QffR93nGsl9JepqUdb3f3bxJaSVF9To1aABkbXeTKO4h4WUiWoDgY1WM1H+
Ymnw6oaB2aQOG+j7p9CCN0KSiC70UuQm3HWCIjOoIeUjxXEIxnbYIQiJYkOnntMV
XgyxlnalRPWBOqV444rQHWb2yF3UJnCrL3RWupzoj6aT60oNj20lDKIkF8EoOgrC
j5zrC5TkG2QQhDSbYUCJdjy96XftUQCPghcXFuq1eCSd8+4FSvS2Jz7WC0nQSvoU
KYtCi222pB7nmXwVz965pmI4KJ7oOA8w4PDzcxClJ3JQNaGr9e+1yZCQHlqMwX4g
LFGX3kEQ5cILa4UzcQ0iBYa6Pw4Q8KZD/hngxTqO3pFkdSokVw/UTjSnItHl7KXa
LR4EtoQYwOm9sjgF0EUzz7b9NzC7zy60MIZ5JbJ8zTyxJ7NfO5PZA1qLjbTKsJrG
Jr3hXYdkDH2XKtvdOPpc
=b5el
-----END PGP SIGNATURE-----

--=-0JnT+V8zZ9Q25vWHZbAQ--

