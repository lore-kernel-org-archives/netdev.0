From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 03/15] hwspinlock: qcom: Add missing MFD_SYSCON dependency
 on HAS_IOMEM
Date: Thu, 03 Mar 2016 11:53:23 +0100
Message-ID: <1850954.4r0iTkATb8@wuerfel>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
 <1456992221-26712-4-git-send-email-k.kozlowski@samsung.com>
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
In-Reply-To: <1456992221-26712-4-git-send-email-k.kozlowski@samsung.com>
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

On Thursday 03 March 2016 17:03:29 Krzysztof Kozlowski wrote:
> diff --git a/drivers/hwspinlock/Kconfig b/drivers/hwspinlock/Kconfig
> index 73a401662853..5ab2d51dc147 100644
> --- a/drivers/hwspinlock/Kconfig
> +++ b/drivers/hwspinlock/Kconfig
> @@ -21,6 +21,7 @@ config HWSPINLOCK_OMAP
>  config HWSPINLOCK_QCOM
>         tristate "Qualcomm Hardware Spinlock device"
>         depends on ARCH_QCOM
> +       depends on HAS_IOMEM    # For MFD_SYSCON
>         select HWSPINLOCK
>         select MFD_SYSCON
>         help
> 

This is only needed if we add "|| COMPILE_TEST", right now the driver
is limited to ARCH_QCOM.

	Arnd
