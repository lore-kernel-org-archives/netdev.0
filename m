From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: Re: [PATCH 3/3][v2] mdio-mux-gpio: use new gpiod_get_array and gpiod_put_array functions
Date: Mon, 09 Feb 2015 10:14:47 +0100
Message-ID: <2302857.SIRJpJWX1o@pcimr>
References: <2017147.PF4WHTmJS4@pcimr> <CAAVeFu+bfTbvbaZ0EVrZzH_zNWDJjfM4oi13g8D+aH_8x6BqaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexandre Courbot <gnurou@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:59041 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932469AbbBIJOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 04:14:51 -0500
In-Reply-To: <CAAVeFu+bfTbvbaZ0EVrZzH_zNWDJjfM4oi13g8D+aH_8x6BqaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 February 2015 14:18:14 Alexandre Courbot wrote:
> On Thu, Jan 22, 2015 at 1:46 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> > Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
> > disposing of GPIO descriptors.
> >
> > Cc: David Miller <davem@davemloft.net>
> > Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> > ---
> > This patch depends on my previous patch "gpiolib: add gpiod_get_array and
> > gpiod_put_array functions".
> >
> > v2: use the new interface
> >
> > Only compile-tested.
> >
> >  drivers/net/phy/mdio-mux-gpio.c |   61 +++++++++++-----------------------------
> >  1 file changed, 18 insertions(+), 43 deletions(-)
> 
> Oh yeah.
> 
> It would be great to have a tested-by for the next revision though.
> 
> Rojhalat, have you been able to test these new interfaces outside of
> this driver?
> 

I have tested the new interface with my FPGA configuration driver (which I
plan to submit eventually). I cannot test the mdio-mux-gpio driver because
I lack the necessary hardware.
