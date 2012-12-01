From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH -next] qlcnic: remove duplicated include from
 qlcnic_sysfs.c
Date: Sat, 1 Dec 2012 06:20:19 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E06021E@AVMB1.qlogic.org>
References: <CAPgLHd9rUSTcdop1coRzR00SxwHtetQ5vHwAfLN_Jw1VjaK68g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:12497
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751251Ab2LAGU1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 01:20:27 -0500
In-Reply-To: <CAPgLHd9rUSTcdop1coRzR00SxwHtetQ5vHwAfLN_Jw1VjaK68g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Yongjun [mailto:weiyj.lk@gmail.com]
> Sent: Friday, November 30, 2012 10:01 PM
> To: Jitendra Kalsaria; Sony Chacko; David Miller
> Cc: yongjun_wei@trendmicro.com.cn; Dept-Eng Linux Driver; netdev
> Subject: [PATCH -next] qlcnic: remove duplicated include from qlcnic_sysfs.c
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Remove duplicated include.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> index 10a702a..bdaa8ce 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> @@ -13,8 +13,6 @@
>  #include <linux/aer.h>
>  #include <linux/log2.h>
> 
> -#include <linux/sysfs.h>
> -
>  int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32
> enable)  {
>  	return -EOPNOTSUPP;

Thanks, Wei.

Acked-by: Sony Chacko <sony.chacko@qlogic.com>
