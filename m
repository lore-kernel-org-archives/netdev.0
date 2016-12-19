From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Mon, 19 Dec 2016 14:14:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0242669@AcuExch.aculab.com>
References: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
 <20161217152122.19677.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: "ak@linux.intel.com" <ak@linux.intel.com>, "davem@davemloft.net"
	<davem@davemloft.net>, "djb@cr.yp.to" <djb@cr.yp.to>, "ebiggers3@gmail.com"
	<ebiggers3@gmail.com>, "hannes@stressinduktion.org"
	<hannes@stressinduktion.org>, "Jason@zx2c4.com" <Jason@zx2c4.com>,
	"jeanphilippe.aumasson@gmail.com" <jeanphilippe.aumasson@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"luto@amacapital.net" <luto@amacapital.net>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "torvalds@linux-foundation.org"
	<torvalds@linux-foundation.org>, "tytso@mit.edu" <tytso@mit.edu>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: 'George Spelvin' <linux@sciencehorizons.net>, "tom@herbertland.com"
	<tom@herbertland.com>
Return-path: <kernel-hardening-return-5699-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161217152122.19677.qmail@ns.sciencehorizons.net>
Content-Language: en-US
List-Id: netdev.vger.kernel.org

From: George Spelvin
> Sent: 17 December 2016 15:21
...
> uint32_t
> hsiphash24(char const *in, size_t len, uint32_t const key[2])
> {
> 	uint32_t c =3D key[0];
> 	uint32_t d =3D key[1];
> 	uint32_t a =3D     0x6c796765 ^ 0x736f6d65;
> 	uint32_t b =3D d ^ 0x74656462 ^ 0x646f7261;

I've not looked closely, but is that (in some sense) duplicating
the key length?
So you could set a =3D key[2] and b =3D key[3] and still have an
working hash - albeit not exactly the one specified.

I'll add another comment here...
Is it worth using the 32bit hash for IP addresses on 64bit systems that
can't do misaligned accessed?

	David
