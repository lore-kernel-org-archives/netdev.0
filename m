From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Tue, 4 Nov 2008 08:57:23 -0700
Message-ID: <fa686aa40811040757m4e36699nf7870258929ed768@mail.gmail.com>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <200811041645.39953.marc.pignat@hevs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
To: "Marc Pignat" <marc.pignat@hevs.ch>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <200811041645.39953.marc.pignat@hevs.ch>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2008 at 8:45 AM, Marc Pignat <marc.pignat@hevs.ch> wrote=
:
> Hi=FC
>
> On Tuesday 04 November 2008, Paulius Zaleckas wrote:
>> make mdio-gpio work with non OpenFirmware gpio implementation.
>
> of_gpio.c provides generic gpio compatible gpios.
>
> Why not remove all OF specific code from this file and add another on=
e
> creating the struct mdio_gpio_platform_data using OF specific functio=
ns?

This is a very simple driver.  There is no need to split it into two
files.  Have two sections of bus binding (OF and non-OF) is just fine.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
