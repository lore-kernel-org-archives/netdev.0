From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 09/15] media: platform: Add missing MFD_SYSCON dependency on HAS_IOMEM
Date: Thu, 3 Mar 2016 13:28:35 +0100
Message-ID: <CAMuHMdX7UC627aN9wo23EDJ7Y+-ryKhVMKH6cvXhnHj9VoG=MA@mail.gmail.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
	<1456992221-26712-10-git-send-email-k.kozlowski@samsung.com>
	<2181866.k24LVvUjTs@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Krzysztof Kozlowski <k.kozlowski@samsung.com>,
	Daniel Lezcano <daniel.lezcano@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Lee Jones <lee.jones@linaro.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Sebastian Reichel <sre@kernel.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Alessandro Zummo <a.zummo@towertech.it>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andy Gross <andy.gross@linaro.org>,
	David Brown <david.brown@linaro.org>,
	Laurent Pi
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <2181866.k24LVvUjTs@wuerfel>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 3, 2016 at 11:57 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> --- a/drivers/media/platform/exynos4-is/Kconfig
>> +++ b/drivers/media/platform/exynos4-is/Kconfig
>> @@ -17,6 +17,7 @@ config VIDEO_S5P_FIMC
>>         tristate "S5P/EXYNOS4 FIMC/CAMIF camera interface driver"
>>         depends on I2C
>>         depends on HAS_DMA
>> +       depends on HAS_IOMEM    # For MFD_SYSCON
>>         select VIDEOBUF2_DMA_CONTIG
>>         select V4L2_MEM2MEM_DEV
>
> This  is guarded by HAS_DMA, which implies HAS_IOMEM afaik.

No systems around with HV-based DMA?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
