From: Simon Xiao <sixiao@microsoft.com>
Subject: RE: [PATCH 1/1] hv_netvsc: fix a netvsc stats typo
Date: Wed, 8 Feb 2017 22:06:57 +0000
Message-ID: <BN3PR03MB22410ABC136E974396BD8BA4C4420@BN3PR03MB2241.namprd03.prod.outlook.com>
References: <1486490605-28980-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Xiao <sixiao@microsoft.com>, KY Srinivasan <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger
 <sthemmin@microsoft.com>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1486490605-28980-1-git-send-email-sixiao@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Please ignore this patch. I will resubmit it to net-next.

> -----Original Message-----
> From: Simon Xiao [mailto:sixiao@microsoft.com]
> Sent: Tuesday, February 7, 2017 10:03 AM
> To: KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; Stephen Hemminger
> <sthemmin@microsoft.com>; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Cc: Simon Xiao <sixiao@microsoft.com>
> Subject: [PATCH 1/1] hv_netvsc: fix a netvsc stats typo
> 
> [This sender failed our fraud detection checks and may not be who they
> appear to be. Learn about spoofing at http://aka.ms/LearnAboutSpoofing]
> 
> Now, return the correct tx_errors stats in netvsc.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> index 72b0c1f..725ac19 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -920,7 +920,7 @@ static void netvsc_get_stats64(struct net_device *net,
>         }
> 
>         t->tx_dropped   = net->stats.tx_dropped;
> -       t->tx_errors    = net->stats.tx_dropped;
> +       t->tx_errors    = net->stats.tx_errors;
> 
>         t->rx_dropped   = net->stats.rx_dropped;
>         t->rx_errors    = net->stats.rx_errors;
> --
> 2.7.4
