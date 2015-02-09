From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH 3/3][v2] mdio-mux-gpio: use new gpiod_get_array and
 gpiod_put_array functions
Date: Mon, 9 Feb 2015 14:18:14 +0900
Message-ID: <CAAVeFu+bfTbvbaZ0EVrZzH_zNWDJjfM4oi13g8D+aH_8x6BqaQ@mail.gmail.com>
References: <2017147.PF4WHTmJS4@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <2017147.PF4WHTmJS4@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 22, 2015 at 1:46 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
> disposing of GPIO descriptors.
>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> ---
> This patch depends on my previous patch "gpiolib: add gpiod_get_array and
> gpiod_put_array functions".
>
> v2: use the new interface
>
> Only compile-tested.
>
>  drivers/net/phy/mdio-mux-gpio.c |   61 +++++++++++-----------------------------
>  1 file changed, 18 insertions(+), 43 deletions(-)

Oh yeah.

It would be great to have a tested-by for the next revision though.

Rojhalat, have you been able to test these new interfaces outside of
this driver?
