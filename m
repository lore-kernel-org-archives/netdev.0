From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] gpio: removes all usage of gpiochip_remove retval
Date: Thu, 29 May 2014 15:14:33 -0700
Message-ID: <5387B149.20408@gmail.com>
References: <1401400492-26175-1-git-send-email-berthe.ab@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linus.walleij@linaro.org, gnurou@gmail.com, m@bues.ch,
	linux-gpio@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	patches@opensource.wolfsonmicro.com, linux-input@vger.kernel.org,
	linux-leds@vger.kernel.org, linux-media@vger.kernel.org,
	linux-samsungsoc@vger.kernel.org, spear-devel@list.st.com,
	platform-driver-x86@vger.kernel.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org
To: abdoulaye berthe <berthe.ab@gmail.com>
Return-path: <linux-leds-owner@vger.kernel.org>
In-Reply-To: <1401400492-26175-1-git-send-email-berthe.ab@gmail.com>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/29/2014 02:54 PM, abdoulaye berthe wrote:

Did you forget a changelog explaining why this is either needed, or even 
a good idea?  I joined the conversation late and don't know why you are 
doing this.

Thanks,
David Daney



> Signed-off-by: abdoulaye berthe <berthe.ab@gmail.com>
> ---
>   arch/arm/common/scoop.c                        | 10 ++--------
>   arch/mips/txx9/generic/setup.c                 |  4 ++--
>   arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c |  3 ++-
>   arch/sh/boards/mach-x3proto/gpio.c             |  6 ++----
>   drivers/bcma/driver_gpio.c                     |  3 ++-
>   drivers/gpio/gpio-74x164.c                     |  8 +++-----
>   drivers/gpio/gpio-adnp.c                       |  9 +--------
>   drivers/gpio/gpio-adp5520.c                    |  8 +-------
>   drivers/gpio/gpio-adp5588.c                    |  6 +-----
>   drivers/gpio/gpio-amd8111.c                    |  3 +--
>   drivers/gpio/gpio-arizona.c                    |  3 ++-
>   drivers/gpio/gpio-cs5535.c                     |  8 +-------
>   drivers/gpio/gpio-da9052.c                     |  3 ++-
>   drivers/gpio/gpio-da9055.c                     |  3 ++-
>   drivers/gpio/gpio-dwapb.c                      |  2 +-
>   drivers/gpio/gpio-em.c                         |  5 +----
>   drivers/gpio/gpio-f7188x.c                     | 18 ++----------------
>   drivers/gpio/gpio-generic.c                    |  3 ++-
>   drivers/gpio/gpio-grgpio.c                     |  4 +---
>   drivers/gpio/gpio-ich.c                        |  9 +--------
>   drivers/gpio/gpio-it8761e.c                    |  6 +-----
>   drivers/gpio/gpio-janz-ttl.c                   |  8 +-------
>   drivers/gpio/gpio-kempld.c                     |  3 ++-
>   drivers/gpio/gpio-lp3943.c                     |  3 ++-
>   drivers/gpio/gpio-lynxpoint.c                  |  5 +----
>   drivers/gpio/gpio-max730x.c                    | 12 ++++--------
>   drivers/gpio/gpio-max732x.c                    |  7 +------
>   drivers/gpio/gpio-mc33880.c                    | 11 +++--------
>   drivers/gpio/gpio-mc9s08dz60.c                 |  3 ++-
>   drivers/gpio/gpio-mcp23s08.c                   | 26 +++++++-------------------
>   drivers/gpio/gpio-ml-ioh.c                     |  8 ++------
>   drivers/gpio/gpio-msm-v2.c                     |  5 +----
>   drivers/gpio/gpio-mxc.c                        |  2 +-
>   drivers/gpio/gpio-octeon.c                     |  3 ++-
>   drivers/gpio/gpio-palmas.c                     |  3 ++-
>   drivers/gpio/gpio-pca953x.c                    |  7 +------
>   drivers/gpio/gpio-pcf857x.c                    |  4 +---
>   drivers/gpio/gpio-pch.c                        | 10 ++--------
>   drivers/gpio/gpio-rc5t583.c                    |  3 ++-
>   drivers/gpio/gpio-rcar.c                       |  5 +----
>   drivers/gpio/gpio-rdc321x.c                    |  7 ++-----
>   drivers/gpio/gpio-sch.c                        | 16 +++-------------
>   drivers/gpio/gpio-sch311x.c                    |  6 ++----
>   drivers/gpio/gpio-sodaville.c                  |  4 +---
>   drivers/gpio/gpio-stmpe.c                      |  8 +-------
>   drivers/gpio/gpio-sx150x.c                     |  7 ++-----
>   drivers/gpio/gpio-syscon.c                     |  3 ++-
>   drivers/gpio/gpio-tb10x.c                      |  5 +----
>   drivers/gpio/gpio-tc3589x.c                    |  8 +-------
>   drivers/gpio/gpio-timberdale.c                 |  5 +----
>   drivers/gpio/gpio-tps6586x.c                   |  3 ++-
>   drivers/gpio/gpio-tps65910.c                   |  3 ++-
>   drivers/gpio/gpio-tps65912.c                   |  3 ++-
>   drivers/gpio/gpio-ts5500.c                     |  6 +++---
>   drivers/gpio/gpio-twl4030.c                    |  4 +---
>   drivers/gpio/gpio-twl6040.c                    |  3 ++-
>   drivers/gpio/gpio-ucb1400.c                    |  2 +-
>   drivers/gpio/gpio-viperboard.c                 | 10 +++-------
>   drivers/gpio/gpio-vx855.c                      |  3 +--
>   drivers/gpio/gpio-wm831x.c                     |  3 ++-
>   drivers/gpio/gpio-wm8350.c                     |  3 ++-
>   drivers/gpio/gpio-wm8994.c                     |  3 ++-
>   drivers/hid/hid-cp2112.c                       |  6 ++----
>   drivers/input/keyboard/adp5588-keys.c          |  4 +---
>   drivers/input/keyboard/adp5589-keys.c          |  4 +---
>   drivers/input/touchscreen/ad7879.c             | 10 +++-------
>   drivers/leds/leds-pca9532.c                    | 10 ++--------
>   drivers/leds/leds-tca6507.c                    |  7 ++-----
>   drivers/media/dvb-frontends/cxd2820r_core.c    | 10 +++-------
>   drivers/mfd/asic3.c                            |  3 ++-
>   drivers/mfd/htc-i2cpld.c                       |  8 +-------
>   drivers/mfd/sm501.c                            | 17 +++--------------
>   drivers/mfd/tc6393xb.c                         | 13 ++++---------
>   drivers/mfd/ucb1x00-core.c                     |  8 ++------
>   drivers/pinctrl/pinctrl-abx500.c               | 15 +++------------
>   drivers/pinctrl/pinctrl-adi2.c                 |  9 ++++-----
>   drivers/pinctrl/pinctrl-as3722.c               | 11 ++---------
>   drivers/pinctrl/pinctrl-baytrail.c             |  5 +----
>   drivers/pinctrl/pinctrl-coh901.c               | 10 ++--------
>   drivers/pinctrl/pinctrl-exynos5440.c           |  6 +-----
>   drivers/pinctrl/pinctrl-msm.c                  | 11 ++---------
>   drivers/pinctrl/pinctrl-nomadik.c              |  2 +-
>   drivers/pinctrl/pinctrl-rockchip.c             | 16 ++++------------
>   drivers/pinctrl/pinctrl-samsung.c              | 14 ++++----------
>   drivers/pinctrl/pinctrl-sunxi.c                |  3 +--
>   drivers/pinctrl/sh-pfc/gpio.c                  |  9 +++------
>   drivers/pinctrl/spear/pinctrl-plgpio.c         |  3 +--
>   drivers/pinctrl/vt8500/pinctrl-wmt.c           |  9 ++-------
>   drivers/platform/x86/intel_pmic_gpio.c         |  3 +--
>   drivers/ssb/driver_gpio.c                      |  3 ++-
>   drivers/staging/vme/devices/vme_pio2_gpio.c    |  4 +---
>   drivers/tty/serial/max310x.c                   | 10 ++++------
>   drivers/video/fbdev/via/via-gpio.c             | 10 +++-------
>   sound/soc/codecs/wm5100.c                      |  5 +----
>   sound/soc/codecs/wm8903.c                      |  6 +-----
>   sound/soc/codecs/wm8962.c                      |  5 +----
>   sound/soc/codecs/wm8996.c                      |  6 +-----
>   97 files changed, 182 insertions(+), 460 deletions(-)
>
[...]
