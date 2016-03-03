From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [rtc-linux] Re: [RFC 04/15] irqchip: st: Add missing MFD_SYSCON
 dependency on HAS_IOMEM
Date: Thu, 03 Mar 2016 13:28:29 +0100
Message-ID: <2188157.YL7RR6FeEK@wuerfel>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
 <2506651.J2Z42d81nD@wuerfel>
 <CAJKOXPcZuyicNAaH6CpOe+bTrLtM1k0tVisS_xJXGDrxyZ_i5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 David Brown <david.brown@linaro.org>, netdev@vger.kernel.org,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Lee Jones <lee.jones@linaro.org>, Thomas Gleixner <tglx@linutronix.de>,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 Vinod Koul <vinod.koul@intel.com>, Daniel Lezcano <daniel.lezcano@linaro.org>,
 Kishon Vijay Abraham I <kishon@ti.com>, Andy Gross <andy.gross@linaro.org>,
 linux-media@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
 rtc-linux@googlegroups.com, Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
 Marc Zyngier <marc.zyngier@arm.com>, linux-arm-msm@vger.kernel.org,
 linux-gpio@vger.kernel.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 Dan Williams <da
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAJKOXPcZuyicNAaH6CpOe+bTrLtM1k0tVisS_xJXGDrxyZ_i5A@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thursday 03 March 2016 21:00:57 Krzysztof Kozlowski wrote:
> >
> > Not user visible.
> 
> Hmmm... you are right (here and in other patches) but why am I getting
> all these errors:
> warning: (ST_IRQCHIP && HIP04_ETH && STMMAC_PLATFORM && DWMAC_IPQ806X
> && DWMAC_LPC18XX && DWMAC_ROCKCHIP && DWMAC_SOCFPGA && DWMAC_STI &&
> TI_CPSW && PINCTRL_ROCKCHIP && PINCTRL_DOVE && POWER_RESET_KEYSTONE &&
> S3C2410_WATCHDOG && VIDEO_OMAP3 && VIDEO_S5P_FIMC && USB_XHCI_MTK &&
> RTC_DRV_AT91SAM9 && LPC18XX_DMAMUX && VIDEO_OMAP4 && HWSPINLOCK_QCOM
> && ATMEL_ST && QCOM_GSBI && PHY_HI6220_USB) selects MFD_SYSCON which
> has unmet direct dependencies (HAS_IOMEM)
> ?
> (ARCH=um, allyesconfig)

The problem is that Kconfig will just print any option that
selects the one that has a missing dependency, but doesn't
show which of those are actually enabled.

> Adding depends here (and in other places) really helps... but it
> should not have any impact...

I think patch 5 by itself would have been sufficient.

	Arnd
