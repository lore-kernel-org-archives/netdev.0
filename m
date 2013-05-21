From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 15/19] drivers/net/irda: add missing platform_driver owner
Date: Tue, 21 May 2013 17:09:35 +0400
Message-ID: <519B720F.9020705@cogentembedded.com>
References: <1369104163-38628-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	lizefan@huawei.com
To: Libo Chen <libo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369104163-38628-1-git-send-email-libo.chen@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 21-05-2013 6:42, Libo Chen wrote:

> set the owner of platform_driver, to ensure that the
> caller of driver holds a module refernece

> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>   drivers/net/irda/bfin_sir.c   |    1 +
>   drivers/net/irda/sh_irda.c    |    1 +
>   drivers/net/irda/sh_sir.c     |    1 +
>   drivers/net/irda/smsc-ircc2.c |    1 +
>   4 files changed, 4 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
> index 22b4527..bf976f3 100644
> --- a/drivers/net/irda/bfin_sir.c
> +++ b/drivers/net/irda/bfin_sir.c
> @@ -806,6 +806,7 @@ static struct platform_driver bfin_ir_driver = {
>   	.resume  = bfin_sir_resume,
>   	.driver  = {
>   		.name = DRIVER_NAME,
> +		.owner	= THIS_MODULE,

    Either indent last = with space as above, or indent both = with tabs.

WBR, Sergei
