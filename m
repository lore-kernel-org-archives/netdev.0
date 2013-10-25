From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to `devm_gpio_request_one'
Date: Fri, 25 Oct 2013 14:21:47 -0700
Message-ID: <526AE0EB.4020602@linux.intel.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com> <20131025044027.GA27083@localhost> <CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com> <1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com> <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com> <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

On 10/25/2013 03:49 AM, Linus Walleij wrote:
> On Fri, Oct 25, 2013 at 12:41 PM, Linus Walleij
> <linus.walleij@linaro.org> wrote:
>
>>> I wouldn't object to adding a dependency to GPIO_PCH and GPIOLIB
>>> unconditionally for PCH_GBE as GPIO_PCH is the same chip... but I don't
>>> know if David Miller would be amenable to that.
>>
>> Well we should probably just stick a dependency to GPIOLIB in there.
>>
>> - It #includes <linux/gpio.h>
>> - It uses gpiolib functions to do something vital
>>
>> It was just happy that dummy versions were slotted in until now.
>
> ...or maybe I'm just confused now?
>
> Should we just add a static inline stub of devm_gpio_request_one()?

I am not familiar with the HW. But checking the code, platform 
initialization should fail with a dummy devm_gpio_request_one()
implementation. IMO it makes more sense to depend on GPIOLIB.

Br, David Cohen
