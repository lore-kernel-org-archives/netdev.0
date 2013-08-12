From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/8] net: fs_enet: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 22:16:02 +0400
Message-ID: <52092662.6040507@cogentembedded.com>
References: <5208E222.60300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	David Miller <davem@davemloft.net>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E222.60300@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2013 05:24 PM, Libo Chen wrote:

> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.

> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>   .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 -
>   1 files changed, 0 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> index 8de53a1..7e3de10 100644
> --- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> +++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> @@ -1122,7 +1122,6 @@ static int fs_enet_remove(struct platform_device *ofdev)
>
>   	fep->ops->free_bd(ndev);
>   	fep->ops->cleanup_data(ndev);
> -	dev_set_drvdata(fep->dev, NULL);
>   	of_node_put(fep->fpi->phy_node);
>   	free_netdev(ndev);
>   	return 0;

    Changelog simply doesn't match the patch.

WBR, Sergei
