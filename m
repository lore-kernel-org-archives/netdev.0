From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Wed, 5 Nov 2008 03:32:55 -0500
Message-ID: <8bd0f97a0811050032i206214a6r8d30a58f354995b4@mail.gmail.com>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <200811042045.41052.david-b@pacbell.net>
	 <8bd0f97a0811042134n3c5543bbwed7a8ebfd0e3f77e@mail.gmail.com>
	 <200811050011.56804.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Grant Likely" <grant.likely@secretlab.ca>,
	"Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>
To: "David Brownell" <david-b@pacbell.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <200811050011.56804.david-b@pacbell.net>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 5, 2008 at 03:11, David Brownell wrote:
> On Tuesday 04 November 2008, Mike Frysinger wrote:
>> > If indeed OF functions don't have declarations which are
>> > available on all platforms, that might be worth fixing
>> > to enable this approach to #ifdef elimination.
>>
>> OF is open firmware right ?  no way there's going to be OF for every
>> port that supports GPIO, so filling out the stubs in linux/of_gpio.h
>> will need to be done.
>
> In which case the boolean "we don't have OF" would be "false" and
> any code referencing the declared functions would be compiled out
> (being dead code/data).  So there would be no link-time references
> to any OF routines... standard technique.

i understand the compiler side just fine.  my point is that the
current linux/of_gpio.h only defines the OF structure and related
prototypes when CONFIG_OF_GPIO is defined.  so it needs updating
first.
-mike
