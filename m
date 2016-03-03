From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 11/15] power: reset: keystone: Add missing MFD_SYSCON
 dependency on HAS_IOMEM
Date: Thu, 03 Mar 2016 12:00:14 +0100
Message-ID: <5230562.E0gg2SNP0m@wuerfel>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
 <1456992221-26712-12-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 David Brown <david.brown@linaro.org>,
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
 Dan Williams <dan.j.williams@intel.com>,
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456992221-26712-12-git-send-email-k.kozlowski@samsung.com>
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

On Thursday 03 March 2016 17:03:37 Krzysztof Kozlowski wrote:
> diff --git a/drivers/power/reset/Kconfig b/drivers/power/reset/Kconfig
> index 0a6408a39c66..0f34846ae80d 100644
> --- a/drivers/power/reset/Kconfig
> +++ b/drivers/power/reset/Kconfig
> @@ -141,6 +141,7 @@ config POWER_RESET_XGENE
>  config POWER_RESET_KEYSTONE
>         bool "Keystone reset driver"
>         depends on ARCH_KEYSTONE
> +       depends on HAS_IOMEM    # For MFD_SYSCON
>         select MFD_SYSCON
>         help
>           Reboot support for the KEYSTONE SoCs.
> 

This is platform specific, but we should probably add || COMPILE_TEST
along with the HAS_IOMEM dependency.

	Arnd
