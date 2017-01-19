From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 0/5] net: ethernet: ti: cpsw: correct common res usage
Date: Thu, 19 Jan 2017 11:33:14 -0600
Message-ID: <36f7fbd0-1f97-fd10-1f2a-81507dff34fd@ti.com>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/19/2017 10:58 AM, Ivan Khoronzhuk wrote:
> This series is intended to remove unneeded redundancies connected with
> common resource usage function.
>
> Since v1:
> - changed name to cpsw_get_usage_count()
> - added comments to open/closw for cpsw_get_usage_count()
> - added patch:
>   net: ethernet: ti: cpsw: clarify ethtool ops changing num of descs
>
> Based on net-next/master
>
> Ivan Khoronzhuk (5):
>   net: ethernet: ti: cpsw: remove dual check from common res usage
>     function
>   net: ethernet: ti: cpsw: don't disable interrupts in ndo_open
>   net: ethernet: ti: cpsw: don't duplicate ndev_running
>   net: ethernet: ti: cpsw: don't duplicate common res in rx handler
>   net: ethernet: ti: cpsw: clarify ethtool ops changing num of descs
>
>  drivers/net/ethernet/ti/cpsw.c | 200 ++++++++++++++++++-----------------------
>  1 file changed, 88 insertions(+), 112 deletions(-)
>

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

-- 
regards,
-grygorii
