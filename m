From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: Re: [PATCH v5 4/4] mdio-mux-gpio: use new gpiod_get_array and gpiod_put_array functions
Date: Thu, 05 Mar 2015 12:57:56 +0100
Message-ID: <5728340.kX3ri7Iz4s@pcimr>
References: <1521782.cXqN30N6pA@pcimr> <7922544.OK5CjAi0mG@pcimr> <CACRpkdaU7cK1LNdhDMBnir0WX92JnT=s6BV-jidNH3i-Ty6HgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexandre Courbot <gnurou@gmail.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:41331 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320AbbCEL6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 06:58:00 -0500
In-Reply-To: <CACRpkdaU7cK1LNdhDMBnir0WX92JnT=s6BV-jidNH3i-Ty6HgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 March 2015 10:04:20 Linus Walleij wrote:
> On Wed, Mar 4, 2015 at 3:33 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> 
> > And the interface as proposed in this series is very convenient for obtaining
> > all the GPIOs belonging to a group with a single function call and without
> > having to know the number of GPIOs within the group beforehand.
> >
> > So if we want to support different use cases, I think it's quite good as it is.
> > People who want to set a group of GPIOs as obtained by gpiod_get_array() can
> > do so with a single call to gpiod_set_array(), the only overhead being that
> > they have to specify the two elements of struct gpiod_descs explicitly.
> > Likewise people who want to set a group of GPIOs obtained with a combination
> > of calls to gpiod_get_array() and gpiod_get() can do so too. They just have
> > to create that group first.
> >
> > On the other hand if gpiod_set_array() would require a struct gpiod_descs as
> > argument the creation of a group for the second use case would become more
> > complicated as you would have to allocate a struct instead of an array, etc.
> >
> > So let's just keep it the way it is and get this series merged.
> 
> I've merged it.
> 

Thanks.

> But can you make a separate patch to Documentation/gpio/consumer.txt
> describing the array usecase(s) a bit in detail so people realize when it's
> good to use these functions?
> 

Sure.

> > About the confusing function names: I would be happy to submit a patch
> > renaming gpiod_set_array() to gpiod_set_array_value(), once this has been
> > merged. I'm a little concerned about the length of some function names though.
> > Isn't gpiod_set_raw_array_value_cansleep() a bit long?
> 
> Just patch it and we'll discuss it... :)
> 

Ok. I'll submit a patch after you've merged patch 4/4 in this series in order
to avoid conflicts.
