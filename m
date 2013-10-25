From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to `devm_gpio_request_one'
Date: Fri, 25 Oct 2013 12:49:31 +0200
Message-ID: <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com>
	<20131025044027.GA27083@localhost>
	<CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com>
	<1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com>
	<CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Cohen <david.a.cohen@linux.intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 25, 2013 at 12:41 PM, Linus Walleij
<linus.walleij@linaro.org> wrote:

>> I wouldn't object to adding a dependency to GPIO_PCH and GPIOLIB
>> unconditionally for PCH_GBE as GPIO_PCH is the same chip... but I don't
>> know if David Miller would be amenable to that.
>
> Well we should probably just stick a dependency to GPIOLIB in there.
>
> - It #includes <linux/gpio.h>
> - It uses gpiolib functions to do something vital
>
> It was just happy that dummy versions were slotted in until now.

...or maybe I'm just confused now?

Should we just add a static inline stub of devm_gpio_request_one()?

Yours,
Linus Walleij
