From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 14/22] fjes: net_device_ops.ndo_tx_timeout
Date: Thu, 18 Jun 2015 16:58:37 +0300
Message-ID: <5582CE8D.1010902@cogentembedded.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com> <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com> <1434588587-25655-14-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>,
	platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33506 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbbFRN6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 09:58:41 -0400
Received: by laka10 with SMTP id a10so55020860lak.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 06:58:40 -0700 (PDT)
In-Reply-To: <1434588587-25655-14-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/18/2015 3:49 AM, Taku Izumi wrote:

> This patch adds net_device_ops.ndo_tx_timeout callback.

> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>   drivers/platform/x86/fjes/fjes_main.c | 9 +++++++++
>   1 file changed, 9 insertions(+)

> diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
> index 72541a7..84727d8 100644
> --- a/drivers/platform/x86/fjes/fjes_main.c
> +++ b/drivers/platform/x86/fjes/fjes_main.c
[...]
> @@ -739,6 +741,13 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *skb,
>   	return ret;
>   }
>
> +static void fjes_tx_retry(struct net_device *netdev)
> +{
> +	struct netdev_queue *curQueue = netdev_get_tx_queue(netdev, 0);

    No CamelCase, please.

WBR, Sergei
