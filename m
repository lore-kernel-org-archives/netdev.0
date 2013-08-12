From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 8/8] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 22:17:47 +0400
Message-ID: <520926CB.4020500@cogentembedded.com>
References: <5208E231.60104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mugunthanvnm@ti.com,
	bigeasy@linutronix.de, prabhakar.csengg@gmail.com, b-liu@ti.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E231.60104@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2013 05:25 PM, Libo Chen wrote:

> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.

> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>   drivers/net/ethernet/ti/davinci_mdio.c |    4 +---
>   1 files changed, 1 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 16ddfc3..2249b2c 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
[...]
> @@ -434,7 +433,6 @@ static int davinci_mdio_remove(struct platform_device *pdev)
>   	pm_runtime_put_sync(&pdev->dev);
>   	pm_runtime_disable(&pdev->dev);
>
> -	dev_set_drvdata(dev, NULL);

    Doesn't get described as well. I think you're mixing two types of changes 
in one patchset.

WBR, Sergei
