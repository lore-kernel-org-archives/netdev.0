From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Wed, 5 Nov 2008 01:11:56 -0700
Message-ID: <200811050011.56804.david-b@pacbell.net>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <200811042045.41052.david-b@pacbell.net> <8bd0f97a0811042134n3c5543bbwed7a8ebfd0e3f77e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Grant Likely" <grant.likely@secretlab.ca>,
	"Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.sbc.mail.sp1.yahoo.com ([69.147.64.90]:36381 "HELO
	smtp117.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752538AbYKEIL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 03:11:59 -0500
In-Reply-To: <8bd0f97a0811042134n3c5543bbwed7a8ebfd0e3f77e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 November 2008, Mike Frysinger wrote:
> > If indeed OF functions don't have declarations which are
> > available on all platforms, that might be worth fixing
> > to enable this approach to #ifdef elimination.
>=20
> OF is open firmware right ? =A0no way there's going to be OF for ever=
y
> port that supports GPIO, so filling out the stubs in linux/of_gpio.h
> will need to be done.

In which case the boolean "we don't have OF" would be "false" and
any code referencing the declared functions would be compiled out
(being dead code/data).  So there would be no link-time references
to any OF routines... standard technique.


