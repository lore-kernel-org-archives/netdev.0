From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v5 2/4] gpiolib: add gpiod_get_array and gpiod_put_array functions
Date: Thu, 5 Mar 2015 09:55:09 +0100
Message-ID: <CACRpkdZS5N62zoD-zPeYM3KOJp1zUWE8yUGXTpZ4msoAXgVj9Q@mail.gmail.com>
References: <3417970.NJsESPLFsD@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <3417970.NJsESPLFsD@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2015 at 5:27 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:

> Introduce new functions for conveniently obtaining and disposing of an entire
> array of GPIOs with one function call.
>
> Suggested-by: Alexandre Courbot <acourbot@nvidia.com>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
>
> ACPI part:
> Reviewed-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> Tested-by: Mika Westerberg <mika.westerberg@linux.intel.com>
>
> DT part:
> Tested-by: Rojhalat Ibrahim <imr@rtschenk.de>
> ---
> Change log:
>   v5: move the ACPI functions to gpiolib-acpi.c
>   v4: - use shorter names for members of struct gpio_descs
>       - rename lut_gpio_count to platform_gpio_count for clarity
>       - add check for successful memory allocation
>       - use ERR_CAST()
>   v3: - rebase on current linux-gpio devel branch
>       - fix ACPI GPIO counting
>       - allow for zero-sized arrays
>       - make the flags argument mandatory for the new functions
>       - clarify documentation
>   v2: change interface

Patch applied with some fuzzing, check that it ended up correctly
in my git (or linux-next).

Yours,
Linus Walleij
