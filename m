From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH][netdev-next] net: hns: make guid hns_dsaf_acpi_dsm_guid
 static
Date: Tue, 13 Jun 2017 17:16:44 +0300
Message-ID: <1497363404.22624.131.camel@linux.intel.com>
References: <20170613130321.7797-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daode Huang <huangdaode@hisilicon.com>,
        Kejian Yan <yankejian@huawei.com>,
        oulijun <oulijun@huawei.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613130321.7797-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-06-13 at 14:03 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The guid hns_dsaf_acpi_dsm_guid does not need to be in global
> scope, so make it static.
> 
> Cleans up sparse warning:
> "symbol 'hns_dsaf_acpi_dsm_guid' was not declared. Should it be
> static?"

Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> index 6b15a507999c..7a8addda726e 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> @@ -29,7 +29,7 @@ enum _dsm_rst_type {
>  	HNS_ROCE_RESET_FUNC     = 0x7,
>  };
>  
> -const guid_t hns_dsaf_acpi_dsm_guid =
> +static const guid_t hns_dsaf_acpi_dsm_guid =
>  	GUID_INIT(0x1A85AA1A, 0xE293, 0x415E,
>  		  0x8E, 0x28, 0x8D, 0x69, 0x0A, 0x0F, 0x82, 0x0A);
>  

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
