From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: Re: [rtc-linux] [RFC 06/15] pinctrl: rockchip: Add missing MFD_SYSCON
 dependency on HAS_IOMEM
Date: Thu, 3 Mar 2016 21:44:44 +0900
Message-ID: <CAJKOXPcbiscpC_RUe=ft9NTy1ZY1uaa_zkX6rOadnoym-UMR1g@mail.gmail.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
	<1456992221-26712-7-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Lezcano <daniel.lezcano@linaro.org>,
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
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, dmaen
To: rtc-linux@googlegroups.com
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1456992221-26712-7-git-send-email-k.kozlowski@samsung.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-03-03 17:03 GMT+09:00 Krzysztof Kozlowski <k.kozlowski@samsung.com>:
> The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
> direct dependencies.
>
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> ---
>  drivers/pinctrl/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/pinctrl/Kconfig b/drivers/pinctrl/Kconfig
> index fb8200b8e8ec..dc7ab58d4d74 100644
> --- a/drivers/pinctrl/Kconfig
> +++ b/drivers/pinctrl/Kconfig
> @@ -131,6 +131,7 @@ config PINCTRL_MESON
>
>  config PINCTRL_ROCKCHIP
>         bool
> +       depends on HAS_IOMEM    # For MFD_SYSCON
>         select PINMUX

False alarm, no need for the patch (non-selectable symbol)

Best regards,
Krzysztof
