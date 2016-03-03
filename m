From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: Re: [rtc-linux] [RFC 13/15] staging: media: omap4iss: Add missing
 MFD_SYSCON dependency on HAS_IOMEM
Date: Thu, 3 Mar 2016 21:42:19 +0900
Message-ID: <CAJKOXPc_16KuX2Wqygdn9u+B7P2TvLEtx07QdXPgiwatXJF8nA@mail.gmail.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
	<1456992221-26712-14-git-send-email-k.kozlowski@samsung.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456992221-26712-14-git-send-email-k.kozlowski@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-03-03 17:03 GMT+09:00 Krzysztof Kozlowski <k.kozlowski@samsung.com>:
> The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
> direct dependencies.
>
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> ---
>  drivers/staging/media/omap4iss/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/staging/media/omap4iss/Kconfig b/drivers/staging/media/omap4iss/Kconfig
> index 46183464ee79..7dea072172aa 100644
> --- a/drivers/staging/media/omap4iss/Kconfig
> +++ b/drivers/staging/media/omap4iss/Kconfig
> @@ -2,6 +2,7 @@ config VIDEO_OMAP4
>         tristate "OMAP 4 Camera support"
>         depends on VIDEO_V4L2 && VIDEO_V4L2_SUBDEV_API && I2C && ARCH_OMAP4
>         depends on HAS_DMA
> +       depends on HAS_IOMEM    # For MFD_SYSCON
>         select MFD_SYSCON
>         select VIDEOBUF2_DMA_CONTIG
>         ---help---

False alarm, no need for the patch (this depends on ARCH_OMAP4).

Best regards,
Krzysztof
