From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Tue, 4 Nov 2008 21:45:40 -0700
Message-ID: <200811042045.41052.david-b@pacbell.net>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <200811041604.22947.david-b@pacbell.net> <8bd0f97a0811041609l3bd474afh7e526be368d4c5cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Grant Likely" <grant.likely@secretlab.ca>,
	"Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <8bd0f97a0811041609l3bd474afh7e526be368d4c5cf@mail.gmail.com>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 November 2008, Mike Frysinger wrote:
> > That's generally the preferred way to handle #ifdeffery.
> > But I could imagine OF isn't (yet?) set up to handle it.
>=20
> i agree completely with the inclination to do it all in C as you've
> suggested and let the compiler do dead code elimination, but that onl=
y
> works if the functions in question are defined everywhere (in other
> words, there's a linux/ api for it). =A0i dont think that's the case =
for
> OF (which is what you were implying?) ...

Only works if the functions are "declared" everywhere;
the stuff that's included in header files.

A "definition" would be available at link time (except
for inlined functions, in headers).  Actual C functions.

If indeed OF functions don't have declarations which are
available on all platforms, that might be worth fixing
to enable this approach to #ifdef elimination.

- Dave
