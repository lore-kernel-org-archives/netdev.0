From: abdoulaye berthe <berthe.ab@gmail.com>
Subject: Re: [PATCH] gpio: removes all usage of gpiochip_remove retval
Date: Fri, 30 May 2014 01:16:22 +0200
Message-ID: <CABprBybQ-Jyk95zCqnoWjjyzhNyHVbsbEhb=vA5d=ZYp95_bFA@mail.gmail.com>
References: <1401400492-26175-1-git-send-email-berthe.ab@gmail.com>
 <5387B149.20408@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2158100788966154146=="
Cc: devel@driverdev.osuosl.org, Alexandre Courbot <gnurou@gmail.com>,
 patches@opensource.wolfsonmicro.com, linux-mips@linux-mips.org,
 netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
 linux-sh@vger.kernel.org, linux-wireless@vger.kernel.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 spear-devel@list.st.com, linux-samsungsoc@vger.kernel.org,
 "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
 linux-leds@vger.kernel.org, m@bues.ch, linux-input@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <5387B149.20408@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============2158100788966154146==
Content-Type: multipart/alternative; boundary=089e0149cbc6081d4a04fa921eaa

--089e0149cbc6081d4a04fa921eaa
Content-Type: text/plain; charset=UTF-8

Hi David,
The aim of this patch is to make gpiochip_remove() behavior consistent,
especially when issuing a remove request while the chipio chip is
still requested. A patch has been submitted to change the return value of
gpiochip_remove() from int to void. This one updates users of the return
value:
Cheers,
Abdoulaye.


On Fri, May 30, 2014 at 12:14 AM, David Daney <ddaney.cavm@gmail.com> wrote:

> On 05/29/2014 02:54 PM, abdoulaye berthe wrote:
>
> Did you forget a changelog explaining why this is either needed, or even a
> good idea?  I joined the conversation late and don't know why you are doing
> this.
>
> Thanks,
> David Daney
>
>
>
>
>  Signed-off-by: abdoulaye berthe <berthe.ab@gmail.com>
>> ---
>>   arch/arm/common/scoop.c                        | 10 ++--------
>>   arch/mips/txx9/generic/setup.c                 |  4 ++--
>>   arch/powerpc/platforms/83xx/mcu_mpc8349emitx.c |  3 ++-
>>   arch/sh/boards/mach-x3proto/gpio.c             |  6 ++----
>>   drivers/bcma/driver_gpio.c                     |  3 ++-
>>   drivers/gpio/gpio-74x164.c                     |  8 +++-----
>>   drivers/gpio/gpio-adnp.c                       |  9 +--------
>>   drivers/gpio/gpio-adp5520.c                    |  8 +-------
>>   drivers/gpio/gpio-adp5588.c                    |  6 +-----
>>   drivers/gpio/gpio-amd8111.c                    |  3 +--
>>   drivers/gpio/gpio-arizona.c                    |  3 ++-
>>   drivers/gpio/gpio-cs5535.c                     |  8 +-------
>>   drivers/gpio/gpio-da9052.c                     |  3 ++-
>>   drivers/gpio/gpio-da9055.c                     |  3 ++-
>>   drivers/gpio/gpio-dwapb.c                      |  2 +-
>>   drivers/gpio/gpio-em.c                         |  5 +----
>>   drivers/gpio/gpio-f7188x.c                     | 18 ++----------------
>>   drivers/gpio/gpio-generic.c                    |  3 ++-
>>   drivers/gpio/gpio-grgpio.c                     |  4 +---
>>   drivers/gpio/gpio-ich.c                        |  9 +--------
>>   drivers/gpio/gpio-it8761e.c                    |  6 +-----
>>   drivers/gpio/gpio-janz-ttl.c                   |  8 +-------
>>   drivers/gpio/gpio-kempld.c                     |  3 ++-
>>   drivers/gpio/gpio-lp3943.c                     |  3 ++-
>>   drivers/gpio/gpio-lynxpoint.c                  |  5 +----
>>   drivers/gpio/gpio-max730x.c                    | 12 ++++--------
>>   drivers/gpio/gpio-max732x.c                    |  7 +------
>>   drivers/gpio/gpio-mc33880.c                    | 11 +++--------
>>   drivers/gpio/gpio-mc9s08dz60.c                 |  3 ++-
>>   drivers/gpio/gpio-mcp23s08.c                   | 26
>> +++++++-------------------
>>   drivers/gpio/gpio-ml-ioh.c                     |  8 ++------
>>   drivers/gpio/gpio-msm-v2.c                     |  5 +----
>>   drivers/gpio/gpio-mxc.c                        |  2 +-
>>   drivers/gpio/gpio-octeon.c                     |  3 ++-
>>   drivers/gpio/gpio-palmas.c                     |  3 ++-
>>   drivers/gpio/gpio-pca953x.c                    |  7 +------
>>   drivers/gpio/gpio-pcf857x.c                    |  4 +---
>>   drivers/gpio/gpio-pch.c                        | 10 ++--------
>>   drivers/gpio/gpio-rc5t583.c                    |  3 ++-
>>   drivers/gpio/gpio-rcar.c                       |  5 +----
>>   drivers/gpio/gpio-rdc321x.c                    |  7 ++-----
>>   drivers/gpio/gpio-sch.c                        | 16 +++-------------
>>   drivers/gpio/gpio-sch311x.c                    |  6 ++----
>>   drivers/gpio/gpio-sodaville.c                  |  4 +---
>>   drivers/gpio/gpio-stmpe.c                      |  8 +-------
>>   drivers/gpio/gpio-sx150x.c                     |  7 ++-----
>>   drivers/gpio/gpio-syscon.c                     |  3 ++-
>>   drivers/gpio/gpio-tb10x.c                      |  5 +----
>>   drivers/gpio/gpio-tc3589x.c                    |  8 +-------
>>   drivers/gpio/gpio-timberdale.c                 |  5 +----
>>   drivers/gpio/gpio-tps6586x.c                   |  3 ++-
>>   drivers/gpio/gpio-tps65910.c                   |  3 ++-
>>   drivers/gpio/gpio-tps65912.c                   |  3 ++-
>>   drivers/gpio/gpio-ts5500.c                     |  6 +++---
>>   drivers/gpio/gpio-twl4030.c                    |  4 +---
>>   drivers/gpio/gpio-twl6040.c                    |  3 ++-
>>   drivers/gpio/gpio-ucb1400.c                    |  2 +-
>>   drivers/gpio/gpio-viperboard.c                 | 10 +++-------
>>   drivers/gpio/gpio-vx855.c                      |  3 +--
>>   drivers/gpio/gpio-wm831x.c                     |  3 ++-
>>   drivers/gpio/gpio-wm8350.c                     |  3 ++-
>>   drivers/gpio/gpio-wm8994.c                     |  3 ++-
>>   drivers/hid/hid-cp2112.c                       |  6 ++----
>>   drivers/input/keyboard/adp5588-keys.c          |  4 +---
>>   drivers/input/keyboard/adp5589-keys.c          |  4 +---
>>   drivers/input/touchscreen/ad7879.c             | 10 +++-------
>>   drivers/leds/leds-pca9532.c                    | 10 ++--------
>>   drivers/leds/leds-tca6507.c                    |  7 ++-----
>>   drivers/media/dvb-frontends/cxd2820r_core.c    | 10 +++-------
>>   drivers/mfd/asic3.c                            |  3 ++-
>>   drivers/mfd/htc-i2cpld.c                       |  8 +-------
>>   drivers/mfd/sm501.c                            | 17 +++--------------
>>   drivers/mfd/tc6393xb.c                         | 13 ++++---------
>>   drivers/mfd/ucb1x00-core.c                     |  8 ++------
>>   drivers/pinctrl/pinctrl-abx500.c               | 15 +++------------
>>   drivers/pinctrl/pinctrl-adi2.c                 |  9 ++++-----
>>   drivers/pinctrl/pinctrl-as3722.c               | 11 ++---------
>>   drivers/pinctrl/pinctrl-baytrail.c             |  5 +----
>>   drivers/pinctrl/pinctrl-coh901.c               | 10 ++--------
>>   drivers/pinctrl/pinctrl-exynos5440.c           |  6 +-----
>>   drivers/pinctrl/pinctrl-msm.c                  | 11 ++---------
>>   drivers/pinctrl/pinctrl-nomadik.c              |  2 +-
>>   drivers/pinctrl/pinctrl-rockchip.c             | 16 ++++------------
>>   drivers/pinctrl/pinctrl-samsung.c              | 14 ++++----------
>>   drivers/pinctrl/pinctrl-sunxi.c                |  3 +--
>>   drivers/pinctrl/sh-pfc/gpio.c                  |  9 +++------
>>   drivers/pinctrl/spear/pinctrl-plgpio.c         |  3 +--
>>   drivers/pinctrl/vt8500/pinctrl-wmt.c           |  9 ++-------
>>   drivers/platform/x86/intel_pmic_gpio.c         |  3 +--
>>   drivers/ssb/driver_gpio.c                      |  3 ++-
>>   drivers/staging/vme/devices/vme_pio2_gpio.c    |  4 +---
>>   drivers/tty/serial/max310x.c                   | 10 ++++------
>>   drivers/video/fbdev/via/via-gpio.c             | 10 +++-------
>>   sound/soc/codecs/wm5100.c                      |  5 +----
>>   sound/soc/codecs/wm8903.c                      |  6 +-----
>>   sound/soc/codecs/wm8962.c                      |  5 +----
>>   sound/soc/codecs/wm8996.c                      |  6 +-----
>>   97 files changed, 182 insertions(+), 460 deletions(-)
>>
>>  [...]
>

--089e0149cbc6081d4a04fa921eaa
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+PGRpdj48ZGl2PkhpIERhdmlkLDxicj48L2Rpdj5UaGUgYWltIG9mIHRo
aXMgcGF0Y2ggaXMgdG8gbWFrZSBncGlvY2hpcF9yZW1vdmUoKSBiZWhhdmlvciBjb25zaXN0ZW50
LCBlc3BlY2lhbGx5IHdoZW4gaXNzdWluZyBhIHJlbW92ZSByZXF1ZXN0IHdoaWxlIHRoZSBjaGlw
aW8gY2hpcCBpcyA8YnI+c3RpbGwgcmVxdWVzdGVkLiBBIHBhdGNoIGhhcyBiZWVuIHN1Ym1pdHRl
ZCB0byBjaGFuZ2UgdGhlIHJldHVybiB2YWx1ZSBvZiBncGlvY2hpcF9yZW1vdmUoKSBmcm9tIGlu
dCB0byB2b2lkLiBUaGlzIG9uZSB1cGRhdGVzIHVzZXJzIG9mIHRoZSByZXR1cm4gdmFsdWU6PGJy
Pg0KDQo8L2Rpdj5DaGVlcnMsPGJyPkFiZG91bGF5ZS48YnI+DQo8L2Rpdj48ZGl2IGNsYXNzPSJn
bWFpbF9leHRyYSI+PGJyPjxicj48ZGl2IGNsYXNzPSJnbWFpbF9xdW90ZSI+T24gRnJpLCBNYXkg
MzAsIDIwMTQgYXQgMTI6MTQgQU0sIERhdmlkIERhbmV5IDxzcGFuIGRpcj0ibHRyIj4mbHQ7PGEg
aHJlZj0ibWFpbHRvOmRkYW5leS5jYXZtQGdtYWlsLmNvbSIgdGFyZ2V0PSJfYmxhbmsiPmRkYW5l
eS5jYXZtQGdtYWlsLmNvbTwvYT4mZ3Q7PC9zcGFuPiB3cm90ZTo8YnI+DQo8YmxvY2txdW90ZSBj
bGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3JkZXItbGVmdDox
cHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij5PbiAwNS8yOS8yMDE0IDAyOjU0IFBNLCBh
YmRvdWxheWUgYmVydGhlIHdyb3RlOjxicj4NCjxicj4NCkRpZCB5b3UgZm9yZ2V0IGEgY2hhbmdl
bG9nIGV4cGxhaW5pbmcgd2h5IHRoaXMgaXMgZWl0aGVyIG5lZWRlZCwgb3IgZXZlbiBhIGdvb2Qg
aWRlYT8gwqBJIGpvaW5lZCB0aGUgY29udmVyc2F0aW9uIGxhdGUgYW5kIGRvbiYjMzk7dCBrbm93
IHdoeSB5b3UgYXJlIGRvaW5nIHRoaXMuPGJyPg0KPGJyPg0KVGhhbmtzLDxicj4NCkRhdmlkIERh
bmV5PGRpdj48ZGl2IGNsYXNzPSJoNSI+PGJyPg0KPGJyPg0KPGJyPg0KPGJyPg0KPGJsb2NrcXVv
dGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7Ym9yZGVyLWxl
ZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQpTaWduZWQtb2ZmLWJ5OiBhYmRv
dWxheWUgYmVydGhlICZsdDs8YSBocmVmPSJtYWlsdG86YmVydGhlLmFiQGdtYWlsLmNvbSIgdGFy
Z2V0PSJfYmxhbmsiPmJlcnRoZS5hYkBnbWFpbC5jb208L2E+Jmd0Ozxicj4NCi0tLTxicj4NCsKg
IGFyY2gvYXJtL2NvbW1vbi9zY29vcC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgfCAxMCArKy0tLS0tLS0tPGJyPg0KwqAgYXJjaC9taXBzL3R4eDkvZ2VuZXJpYy9zZXR1cC5j
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqA0ICsrLS08YnI+DQrCoCBhcmNoL3Bvd2VycGMv
cGxhdGZvcm1zLzgzeHgvPHU+PC91Pm1jdV9tcGM4MzQ5ZW1pdHguYyB8IMKgMyArKy08YnI+DQrC
oCBhcmNoL3NoL2JvYXJkcy9tYWNoLXgzcHJvdG8vPHU+PC91PmdwaW8uYyDCoCDCoCDCoCDCoCDC
oCDCoCB8IMKgNiArKy0tLS08YnI+DQrCoCBkcml2ZXJzL2JjbWEvZHJpdmVyX2dwaW8uYyDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgMyArKy08YnI+DQrCoCBkcml2ZXJzL2dwaW8v
Z3Bpby03NHgxNjQuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgOCArKystLS0t
LTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLWFkbnAuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCB8IMKgOSArLS0tLS0tLS08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby1hZHA1
NTIwLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IMKgOCArLS0tLS0tLTxicj4NCsKg
IGRyaXZlcnMvZ3Bpby9ncGlvLWFkcDU1ODguYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oHwgwqA2ICstLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLWFtZDgxMTEuYyDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqAzICstLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlv
LWFyaXpvbmEuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqAzICsrLTxicj4NCsKg
IGRyaXZlcnMvZ3Bpby9ncGlvLWNzNTUzNS5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IHwgwqA4ICstLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tZGE5MDUyLmMgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dw
aW8tZGE5MDU1LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJyPg0K
wqAgZHJpdmVycy9ncGlvL2dwaW8tZHdhcGIuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoHwgwqAyICstPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tZW0uYyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgNSArLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9n
cGlvLWY3MTg4eC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgMTggKystLS0tLS0t
LS0tLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tZ2VuZXJpYy5jIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgfCDCoDMgKystPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tZ3Jn
cGlvLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDQgKy0tLTxicj4NCsKgIGRy
aXZlcnMvZ3Bpby9ncGlvLWljaC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
fCDCoDkgKy0tLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8taXQ4NzYxZS5jIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfCDCoDYgKy0tLS0tPGJyPg0KwqAgZHJpdmVycy9ncGlv
L2dwaW8tamFuei10dGwuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgOCArLS0tLS0t
LTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLWtlbXBsZC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIHwgwqAzICsrLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLWxwMzk0My5jIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqAzICsrLTxicj4NCsKgIGRyaXZlcnMvZ3Bp
by9ncGlvLWx5bnhwb2ludC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfCDCoDUgKy0tLS08
YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby1tYXg3MzB4LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqB8IDEyICsrKystLS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLW1heDcz
MnguYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqA3ICstLS0tLS08YnI+DQrCoCBk
cml2ZXJzL2dwaW8vZ3Bpby1tYzMzODgwLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8
IDExICsrKy0tLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tbWM5czA4ZHo2MC5jIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqAzICsrLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlv
LW1jcDIzczA4LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCAyNiArKysrKysrLS0tLS0t
LS0tLS0tLS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLW1sLWlvaC5jIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqA4ICsrLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9ncGlv
L2dwaW8tbXNtLXYyLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDUgKy0tLS08
YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby1teGMuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoHwgwqAyICstPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tb2N0ZW9uLmMgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJyPg0KwqAgZHJpdmVycy9ncGlv
L2dwaW8tcGFsbWFzLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJy
Pg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tcGNhOTUzeC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgfCDCoDcgKy0tLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXBjZjg1N3guYyDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqA0ICstLS08YnI+DQrCoCBkcml2ZXJzL2dw
aW8vZ3Bpby1wY2guYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgMTAgKyst
LS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXJjNXQ1ODMuYyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoHwgwqAzICsrLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXJjYXIu
YyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgNSArLS0tLTxicj4NCsKgIGRy
aXZlcnMvZ3Bpby9ncGlvLXJkYzMyMXguYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwg
wqA3ICsrLS0tLS08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby1zY2guYyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgMTYgKysrLS0tLS0tLS0tLS0tLTxicj4NCsKgIGRyaXZl
cnMvZ3Bpby9ncGlvLXNjaDMxMXguYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqA2
ICsrLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXNvZGF2aWxsZS5jIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgfCDCoDQgKy0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXN0bXBl
LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IMKgOCArLS0tLS0tLTxicj4NCsKg
IGRyaXZlcnMvZ3Bpby9ncGlvLXN4MTUweC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IHwgwqA3ICsrLS0tLS08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby1zeXNjb24uYyDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgMyArKy08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bp
by10YjEweC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfCDCoDUgKy0tLS08YnI+
DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby10YzM1ODl4LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqB8IMKgOCArLS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXRpbWJlcmRhbGUu
YyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgNSArLS0tLTxicj4NCsKgIGRyaXZlcnMvZ3Bp
by9ncGlvLXRwczY1ODZ4LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJy
Pg0KwqAgZHJpdmVycy9ncGlvL2dwaW8tdHBzNjU5MTAuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCB8IMKgMyArKy08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby10cHM2NTkxMi5jIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqAzICsrLTxicj4NCsKgIGRyaXZlcnMvZ3Bpby9ncGlv
LXRzNTUwMC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqA2ICsrKy0tLTxicj4N
CsKgIGRyaXZlcnMvZ3Bpby9ncGlvLXR3bDQwMzAuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoHwgwqA0ICstLS08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby10d2w2MDQwLmMgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IMKgMyArKy08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bp
by11Y2IxNDAwLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IMKgMiArLTxicj4NCsKg
IGRyaXZlcnMvZ3Bpby9ncGlvLXZpcGVyYm9hcmQuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8
IDEwICsrKy0tLS0tLS08YnI+DQrCoCBkcml2ZXJzL2dwaW8vZ3Bpby12eDg1NS5jIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfCDCoDMgKy0tPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dw
aW8td204MzF4LmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJyPg0K
wqAgZHJpdmVycy9ncGlvL2dwaW8td204MzUwLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgfCDCoDMgKystPGJyPg0KwqAgZHJpdmVycy9ncGlvL2dwaW8td204OTk0LmMgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDMgKystPGJyPg0KwqAgZHJpdmVycy9oaWQvaGlkLWNw
MjExMi5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgwqA2ICsrLS0tLTxicj4N
CsKgIGRyaXZlcnMvaW5wdXQva2V5Ym9hcmQvPHU+PC91PmFkcDU1ODgta2V5cy5jIMKgIMKgIMKg
IMKgIMKgfCDCoDQgKy0tLTxicj4NCsKgIGRyaXZlcnMvaW5wdXQva2V5Ym9hcmQvPHU+PC91PmFk
cDU1ODkta2V5cy5jIMKgIMKgIMKgIMKgIMKgfCDCoDQgKy0tLTxicj4NCsKgIGRyaXZlcnMvaW5w
dXQvdG91Y2hzY3JlZW4vPHU+PC91PmFkNzg3OS5jIMKgIMKgIMKgIMKgIMKgIMKgIHwgMTAgKysr
LS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvbGVkcy9sZWRzLXBjYTk1MzIuYyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoHwgMTAgKystLS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvbGVkcy9sZWRz
LXRjYTY1MDcuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqA3ICsrLS0tLS08YnI+
DQrCoCBkcml2ZXJzL21lZGlhL2R2Yi1mcm9udGVuZHMvPHU+PC91PmN4ZDI4MjByX2NvcmUuYyDC
oCDCoHwgMTAgKysrLS0tLS0tLTxicj4NCsKgIGRyaXZlcnMvbWZkL2FzaWMzLmMgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IMKgMyArKy08YnI+DQrCoCBkcml2ZXJz
L21mZC9odGMtaTJjcGxkLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDgg
Ky0tLS0tLS08YnI+DQrCoCBkcml2ZXJzL21mZC9zbTUwMS5jIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgfCAxNyArKystLS0tLS0tLS0tLS0tLTxicj4NCsKgIGRyaXZl
cnMvbWZkL3RjNjM5M3hiLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCAx
MyArKysrLS0tLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9tZmQvdWNiMXgwMC1jb3JlLmMgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDggKystLS0tLS08YnI+DQrCoCBkcml2ZXJzL3Bp
bmN0cmwvcGluY3RybC08dT48L3U+YWJ4NTAwLmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfCAxNSAr
KystLS0tLS0tLS0tLS08YnI+DQrCoCBkcml2ZXJzL3BpbmN0cmwvcGluY3RybC1hZGkyLmMgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgfCDCoDkgKysrKy0tLS0tPGJyPg0KwqAgZHJpdmVycy9waW5j
dHJsL3BpbmN0cmwtPHU+PC91PmFzMzcyMi5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHwgMTEgKyst
LS0tLS0tLS08YnI+DQrCoCBkcml2ZXJzL3BpbmN0cmwvcGluY3RybC08dT48L3U+YmF5dHJhaWwu
YyDCoCDCoCDCoCDCoCDCoCDCoCB8IMKgNSArLS0tLTxicj4NCsKgIGRyaXZlcnMvcGluY3RybC9w
aW5jdHJsLTx1PjwvdT5jb2g5MDEuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCB8IDEwICsrLS0tLS0t
LS08YnI+DQrCoCBkcml2ZXJzL3BpbmN0cmwvcGluY3RybC08dT48L3U+ZXh5bm9zNTQ0MC5jIMKg
IMKgIMKgIMKgIMKgIHwgwqA2ICstLS0tLTxicj4NCsKgIGRyaXZlcnMvcGluY3RybC9waW5jdHJs
LW1zbS5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfCAxMSArKy0tLS0tLS0tLTxicj4NCsKg
IGRyaXZlcnMvcGluY3RybC9waW5jdHJsLTx1PjwvdT5ub21hZGlrLmMgwqAgwqAgwqAgwqAgwqAg
wqAgwqB8IMKgMiArLTxicj4NCsKgIGRyaXZlcnMvcGluY3RybC9waW5jdHJsLTx1PjwvdT5yb2Nr
Y2hpcC5jIMKgIMKgIMKgIMKgIMKgIMKgIHwgMTYgKysrKy0tLS0tLS0tLS0tLTxicj4NCsKgIGRy
aXZlcnMvcGluY3RybC9waW5jdHJsLTx1PjwvdT5zYW1zdW5nLmMgwqAgwqAgwqAgwqAgwqAgwqAg
wqB8IDE0ICsrKystLS0tLS0tLS0tPGJyPg0KwqAgZHJpdmVycy9waW5jdHJsL3BpbmN0cmwtc3Vu
eGkuPHU+PC91PmMgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IMKgMyArLS08YnI+DQrCoCBkcml2
ZXJzL3BpbmN0cmwvc2gtcGZjL2dwaW8uYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqA5
ICsrKy0tLS0tLTxicj4NCsKgIGRyaXZlcnMvcGluY3RybC9zcGVhci9waW5jdHJsLTx1PjwvdT5w
bGdwaW8uYyDCoCDCoCDCoCDCoCB8IMKgMyArLS08YnI+DQrCoCBkcml2ZXJzL3BpbmN0cmwvdnQ4
NTAwLzx1PjwvdT5waW5jdHJsLXdtdC5jIMKgIMKgIMKgIMKgIMKgIHwgwqA5ICsrLS0tLS0tLTxi
cj4NCsKgIGRyaXZlcnMvcGxhdGZvcm0veDg2L2ludGVsXzx1PjwvdT5wbWljX2dwaW8uYyDCoCDC
oCDCoCDCoCB8IMKgMyArLS08YnI+DQrCoCBkcml2ZXJzL3NzYi9kcml2ZXJfZ3Bpby5jIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfCDCoDMgKystPGJyPg0KwqAgZHJpdmVycy9zdGFn
aW5nL3ZtZS9kZXZpY2VzLzx1PjwvdT52bWVfcGlvMl9ncGlvLmMgwqAgwqB8IMKgNCArLS0tPGJy
Pg0KwqAgZHJpdmVycy90dHkvc2VyaWFsL21heDMxMHguYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCB8IDEwICsrKystLS0tLS08YnI+DQrCoCBkcml2ZXJzL3ZpZGVvL2ZiZGV2L3ZpYS92aWEt
PHU+PC91PmdwaW8uYyDCoCDCoCDCoCDCoCDCoCDCoCB8IDEwICsrKy0tLS0tLS08YnI+DQrCoCBz
b3VuZC9zb2MvY29kZWNzL3dtNTEwMC5jIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
fCDCoDUgKy0tLS08YnI+DQrCoCBzb3VuZC9zb2MvY29kZWNzL3dtODkwMy5jIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgfCDCoDYgKy0tLS0tPGJyPg0KwqAgc291bmQvc29jL2NvZGVj
cy93bTg5NjIuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgwqA1ICstLS0tPGJy
Pg0KwqAgc291bmQvc29jL2NvZGVjcy93bTg5OTYuYyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoHwgwqA2ICstLS0tLTxicj4NCsKgIDk3IGZpbGVzIGNoYW5nZWQsIDE4MiBpbnNlcnRp
b25zKCspLCA0NjAgZGVsZXRpb25zKC0pPGJyPg0KPGJyPg0KPC9ibG9ja3F1b3RlPjwvZGl2Pjwv
ZGl2Pg0KWy4uLl08YnI+DQo8L2Jsb2NrcXVvdGU+PC9kaXY+PGJyPjwvZGl2Pg0K
--089e0149cbc6081d4a04fa921eaa--

--===============2158100788966154146==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============2158100788966154146==--
