From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Wed, 5 Nov 2008 14:59:08 -0800
Message-ID: <200811051459.08777.david-b@pacbell.net>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <49116000.7000005@teltonika.lt> <fa686aa40811050704s2775fba8nc957a23cb81bb21d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	"Mike Frysinger" <vapier.adi@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <fa686aa40811050704s2775fba8nc957a23cb81bb21d@mail.gmail.com>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 05 November 2008, Grant Likely wrote:
> > 	=A0Maybe the best solution is
> > to write separate driver for OF which will be just wrapper for plat=
form
> > driver... Just like you suggested.

I'd certainly prefer that:  packaging all the OF glue in
a small bit of OF glue code, which doesn't need to affect
the majority of platforms (which don't and won't use OF).


> More complex than necessary. =A0Just give the driver 2 blocks of bind=
ing
> code; one for OF, one for non-OF. =A0No need to split up the driver.

The preceding discussion pointed out ways the "2 blocks"
approach doesn't currently work well ... minimally, there
is currently no way to do that without much ugly #ifdeffing.

And clearly, you and I view this a bit differently.  I'm
happier to think of these kinds of configuration as one
driver plus *separate* platform glue, while you want to be
modifying every driver to accomodate OF.  Or, by extension,
ACPI and any other hardware abstraction layer that comes
along.

- Dave
