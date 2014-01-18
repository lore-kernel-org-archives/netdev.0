From: Jonathan Cameron <jic23@kernel.org>
Subject: Re: [PATCH 7/7] staging,lpc32xx_adc: Add dependency on HAS_IOMEM
Date: Sat, 18 Jan 2014 11:50:16 +0000
Message-ID: <52DA6A78.9040609@kernel.org>
References: <1389714345-20165-1-git-send-email-richard@nod.at>
 <1389714345-20165-7-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: marex@denx.de, lars@metafoo.de, linux-iio@vger.kernel.org,
 netdev@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, acourbot@nvidia.com, devel@driverdev.osuosl.org,
 florian@openwrt.org, sebastian.hesselbarth@gmail.com
To: Richard Weinberger <richard@nod.at>, kishon@ti.com, anton@enomsg.org,
 dwmw2@infradead.org, richardcochran@gmail.com, lidza.louina@gmail.com,
 gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1389714345-20165-7-git-send-email-richard@nod.at>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



On 14/01/14 15:45, Richard Weinberger wrote:
> On archs like S390 or um this driver cannot build nor work.
> Make it depend on HAS_IOMEM to bypass build failures.
>
> drivers/built-in.o: In function `lpc32xx_adc_probe':
> drivers/staging/iio/adc/lpc32xx_adc.c:149: undefined reference to `devm_ioremap'
>
> Signed-off-by: Richard Weinberger <richard@nod.at>
applied to the fixes-togreg branch of iio.git

Thanks,
> ---
>   drivers/staging/iio/adc/Kconfig | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/staging/iio/adc/Kconfig b/drivers/staging/iio/adc/Kconfig
> index 7d5d675..3633298 100644
> --- a/drivers/staging/iio/adc/Kconfig
> +++ b/drivers/staging/iio/adc/Kconfig
> @@ -103,6 +103,7 @@ config AD7280
>   config LPC32XX_ADC
>   	tristate "NXP LPC32XX ADC"
>   	depends on ARCH_LPC32XX || COMPILE_TEST
> +	depends on HAS_IOMEM
>   	help
>   	  Say yes here to build support for the integrated ADC inside the
>   	  LPC32XX SoC. Note that this feature uses the same hardware as the
>
