From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] sha512: make it work, undo percpu message schedule
Date: Sat, 14 Jan 2012 23:00:39 +0100
Message-ID: <1326578439.5287.43.camel@edumazet-laptop>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120112235514.GA5065@p183.telecom.by>
	 <20120113070813.GA20068@gondor.apana.org.au>
	 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
	 <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120114182024.GA4207@p183.telecom.by>
	 <20120114182737.GB4207@p183.telecom.by>
	 <1326577610.5287.38.camel@edumazet-laptop>
	 <CA+55aFxfKyqm9eC_XajLYJ6D5YhHn_9K0pkG+caZDhxrAwvA0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxfKyqm9eC_XajLYJ6D5YhHn_9K0pkG+caZDhxrAwvA0w@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 14 janvier 2012 =C3=A0 13:52 -0800, Linus Torvalds a =C3=A9cr=
it :
> On Sat, Jan 14, 2012 at 1:46 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > This is too risky, and we provided an alternate patch, not just for=
 fun.
>=20
> Did you see the second patch?
>=20

I saw it and felt it was not a stable material.

And Herbert sent an alternate patch, then I sent a V3 patch.

> The one that got rid of the *stupid* 80-entry array?
>=20

Maybe, I didnt wrote this code, and I am very glad this code can be
smarter and all.
