From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 09/10] net: hns: adds limitation for debug port mtu
Date: Mon, 21 Mar 2016 17:17:49 +0300
Message-ID: <56F0028D.4070500@cogentembedded.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1458558401-190165-10-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yankejian@huawei.com, huangdaode@hisilicon.com,
	salil.mehta@huawei.com, lisheng011@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, arnd@arndb.de,
	xieqianqian@huawei.com, andrew@lunn.ch, ivecera@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33504 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289AbcCUORy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 10:17:54 -0400
Received: by mail-lf0-f49.google.com with SMTP id h198so108984429lfh.0
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 07:17:53 -0700 (PDT)
In-Reply-To: <1458558401-190165-10-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/21/2016 02:06 PM, Yisen Zhuang wrote:

> From: Kejian Yan <yankejian@huawei.com>
>
> If mtu for debug port is set more than 1500, it may cause that packets
> are dropped by ppe. So maximum value for debug port should be 1500.
>
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
[...]
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
> index a69c8af..a68efd6 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
> @@ -28,6 +28,7 @@ struct dsaf_device;
>   #define MAC_MAX_MTU		9600
>   #define MAC_MAX_MTU_V2		9728
>   #define MAC_MIN_MTU		68
> +#define MAC_MAX_MTU_DBG         MAC_DEFAULT_MTU

    Please use tabs, not spaces to indent the value, like above

[...]

MBR, Sergei
