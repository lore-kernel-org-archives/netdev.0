From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH] drivers/net/can/m_can/Kconfig: Let CAN_M_CAN depend on
 HAS_IOMEM
Date: Sat, 04 Oct 2014 16:35:10 +0530
Message-ID: <542FD466.6080603@gmail.com>
References: <542FC556.6060306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chen Gang <gang.chen.5i5j@gmail.com>, wg@grandegger.com,
	mkl@pengutronix.de, fengguang.wu@intel.com, b29396@freescale.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <542FC556.6060306@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chen Gang


I think commit message should be short and proper.

We can remove *drivers/net/can/m_can/Kconfig* in the commit, just
give *can: Kconfig: *

commit message like : *can: Kconfig: Fix CAN_M_CAN dependency*

On Saturday 04 October 2014 03:30 PM, Chen Gang wrote:
> CAN_M_CAN needs HAS_IOMEM, so depend on it, the related error (with
> allmodconfig under um):
>
>      MODPOST 1205 modules
>    ERROR: "devm_ioremap" [drivers/net/can/m_can/m_can.ko] undefined!
>    ERROR: "devm_ioremap_resource" [drivers/net/can/m_can/m_can.ko] undefined!
>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>   drivers/net/can/m_can/Kconfig | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/can/m_can/Kconfig b/drivers/net/can/m_can/Kconfig
> index fca5482..14c9fcf 100644
> --- a/drivers/net/can/m_can/Kconfig
> +++ b/drivers/net/can/m_can/Kconfig
> @@ -1,4 +1,5 @@
>   config CAN_M_CAN
>   	tristate "Bosch M_CAN devices"
> +	depends on HAS_IOMEM
>   	---help---
>   	  Say Y here if you want to support for Bosch M_CAN controller.

-- 
Thanks and Regards,
Varka Bhadram.

