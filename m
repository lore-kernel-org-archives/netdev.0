From: Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/7] staging,spear_adc: Add dependency on HAS_IOMEM
Date: Sat, 18 Jan 2014 11:41:28 +0000
Message-ID: <52DA6868.9020401@kernel.org>
References: <1389714345-20165-1-git-send-email-richard@nod.at> <1389714345-20165-3-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org,
	marex-ynQEQJNshbs@public.gmane.org, acourbot-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	driverdev-devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, kishon-l0cyMroinI0@public.gmane.org,
	anton-9xeibp6oKSgdnm+yROfE0A@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	lidza.louina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1389714345-20165-3-git-send-email-richard-/L3Ra7n9ekc@public.gmane.org>
Sender: linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 14/01/14 15:45, Richard Weinberger wrote:
> On archs like S390 or um this driver cannot build nor work.
> Make it depend on HAS_IOMEM to bypass build failures.
>
> drivers/staging/iio/adc/spear_adc.c: In function =E2=80=98spear_adc_p=
robe=E2=80=99:
> drivers/staging/iio/adc/spear_adc.c:393:2: error: implicit declaratio=
n of function =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-de=
claration
>
> Signed-off-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Applied to the fixes-togreg branch of iio.git

Thanks,
> ---
>   drivers/staging/iio/adc/Kconfig | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/staging/iio/adc/Kconfig b/drivers/staging/iio/ad=
c/Kconfig
> index e3d6430..7d5d675 100644
> --- a/drivers/staging/iio/adc/Kconfig
> +++ b/drivers/staging/iio/adc/Kconfig
> @@ -128,6 +128,7 @@ config MXS_LRADC
>   config SPEAR_ADC
>   	tristate "ST SPEAr ADC"
>   	depends on PLAT_SPEAR || COMPILE_TEST
> +	depends on HAS_IOMEM
>   	help
>   	  Say yes here to build support for the integrated ADC inside the
>   	  ST SPEAr SoC. Provides direct access via sysfs.
>
