From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH][v3] mdio-mux-gpio: Use GPIO descriptor interface and new
 gpiod_set_array function
Date: Fri, 28 Nov 2014 13:30:40 +0900
Message-ID: <CAAVeFuLDgLXGAedBYOWJqEJvxFAOAv_z6rwHpPyYVZyXx5XHgQ@mail.gmail.com>
References: <1581158.UhESICdgeM@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1581158.UhESICdgeM@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 10:57 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> Convert mdio-mux-gpio to the GPIO descriptor interface and use the new
> gpiod_set_array function to set all output signals simultaneously.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Acked-by: David S. Miller <davem@davemloft.net>
> --
> This patch depends on the gpiod_set_array function, which is available in
> the linux-gpio devel tree.
>
> Change log:
>   v3: remove unnecessary braces
>   v2: fix gpiod_get_index usage
>
>  drivers/net/phy/mdio-mux-gpio.c |   37 +++++++++++++------------------------
>  1 file changed, 13 insertions(+), 24 deletions(-)

Looks all good to me! Nice use of this new interface, leading to
simpler client code.

Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
