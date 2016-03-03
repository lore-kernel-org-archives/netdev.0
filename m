From: =?UTF-8?Q?Krzysztof_Koz=C5=82owski?= <k.kozlowski.k@gmail.com>
Subject: Re: [rtc-linux] Re: [RFC 04/15] irqchip: st: Add missing MFD_SYSCON
 dependency on HAS_IOMEM
Date: Thu, 3 Mar 2016 21:33:25 +0900
Message-ID: <CAJKOXPeQ2=qqJn0HY2Vx+9J+LOQj-K2ETa2yHqk=Ut5rBPxqPg@mail.gmail.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
	<2506651.J2Z42d81nD@wuerfel>
	<CAJKOXPcZuyicNAaH6CpOe+bTrLtM1k0tVisS_xJXGDrxyZ_i5A@mail.gmail.com>
	<2188157.YL7RR6FeEK@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel@lists.infradead.org, rtc-linux@googlegroups.com,
	Linus Walleij <linus.walleij@linaro.org>,
	Sebastian Reichel <sre@kernel.org>,
	David Brown <david.brown@linaro.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Lee Jones <lee.jones@linaro.org>,
	Dan Williams <dan.j.williams@intel.com>,
	devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
	Vinod Koul <vinod.koul@intel.com>,
	Daniel Lezcano <daniel.lezcano@linaro.org>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	Andy Gross <andy.gross@linaro.org>,
	linux-media@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Marc Zyngier <marc.zyngier@arm.com>,
	linux-arm-msm@vger.kernel.org, linux-gpio@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Thomas Gleixner <tglx@linutronix.de
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <2188157.YL7RR6FeEK@wuerfel>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-03-03 21:28 GMT+09:00 Arnd Bergmann <arnd@arndb.de>:
> On Thursday 03 March 2016 21:00:57 Krzysztof Kozlowski wrote:
>> >
>> > Not user visible.
>>
>> Hmmm... you are right (here and in other patches) but why am I getting
>> all these errors:
>> warning: (ST_IRQCHIP && HIP04_ETH && STMMAC_PLATFORM && DWMAC_IPQ806X
>> && DWMAC_LPC18XX && DWMAC_ROCKCHIP && DWMAC_SOCFPGA && DWMAC_STI &&
>> TI_CPSW && PINCTRL_ROCKCHIP && PINCTRL_DOVE && POWER_RESET_KEYSTONE &&
>> S3C2410_WATCHDOG && VIDEO_OMAP3 && VIDEO_S5P_FIMC && USB_XHCI_MTK &&
>> RTC_DRV_AT91SAM9 && LPC18XX_DMAMUX && VIDEO_OMAP4 && HWSPINLOCK_QCOM
>> && ATMEL_ST && QCOM_GSBI && PHY_HI6220_USB) selects MFD_SYSCON which
>> has unmet direct dependencies (HAS_IOMEM)
>> ?
>> (ARCH=um, allyesconfig)
>
> The problem is that Kconfig will just print any option that
> selects the one that has a missing dependency, but doesn't
> show which of those are actually enabled.

Indeed... but apparently putting direct HAS_IOMEM dependency on these
symbols silences the Kconfig warning.

>> Adding depends here (and in other places) really helps... but it
>> should not have any impact...
>
> I think patch 5 by itself would have been sufficient.

Thanks for analysis. Since all patches are independent (and IMHO the
last one is not needed really) so I won't resend the patchset. Instead
let maintainer pick what is meaningful.

Best regards,
Krzysztof
