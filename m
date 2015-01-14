From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 14 Jan 2015 09:53:34 +0100
Message-ID: <3131780.HetDHI4Cfl@wuerfel>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, davem@davemloft.net, grant.likely@linaro.org,
	agraf@suse.de, sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:55282 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754935AbbANI4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 03:56:09 -0500
In-Reply-To: <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 January 2015 14:34:14 Ding Tianhong wrote:
> +#define HIP04_MAX_TX_COALESCE_USECS    200
> +#define HIP04_MIN_TX_COALESCE_USECS    100
> +#define HIP04_MAX_TX_COALESCE_FRAMES   200
> +#define HIP04_MIN_TX_COALESCE_FRAMES   100

It's not important, but in case you are creating another version of the
patch, maybe the allowed range can be extended somewhat. The example values
I picked when I sent my suggestion were really made up. It's great if
they work fine, but users might want to  tune this far more depending on
their workloads,  How about these

#define HIP04_MAX_TX_COALESCE_USECS    100000
#define HIP04_MIN_TX_COALESCE_USECS    1
#define HIP04_MAX_TX_COALESCE_FRAMES   (TX_DESC_NUM - 1)
#define HIP04_MIN_TX_COALESCE_FRAMES   1

	Arnd
