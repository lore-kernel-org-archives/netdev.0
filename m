From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2 2/3] net: davinci_mdio: Convert pr_err() to dev_err()
 call
Date: Thu, 8 May 2014 16:50:41 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63AD20DC@avmb3.qlogic.org>
References: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
 <1399542652-14900-3-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"balbi@ti.com" <balbi@ti.com>,
	"zonque@gmail.com" <zonque@gmail.com>,
	"mpa@pengutronix.de" <mpa@pengutronix.de>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>
To: George Cherian <george.cherian@ti.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3827 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751295AbaEHQvb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 12:51:31 -0400
In-Reply-To: <1399542652-14900-3-git-send-email-george.cherian@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also, Convert kzalloc to devm_kzalloc.

Looks like you should remove this part of the comment.

>
> Signed-off-by: George Cherian <george.cherian@ti.com>
> Reviewed-by: Felipe Balbi <balbi@ti.com>
> ---
>  drivers/net/ethernet/ti/davinci_mdio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c
> b/drivers/net/ethernet/ti/davinci_mdio.c
> index 34e97ec..735dc53 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -303,7 +303,7 @@ static int davinci_mdio_probe_dt(struct
> mdio_platform_data *data,
>               return -EINVAL;
>
>       if (of_property_read_u32(node, "bus_freq", &prop)) {
> -             pr_err("Missing bus_freq property in the DT.\n");
> +             dev_err(&pdev->dev, "Missing bus_freq property in the DT.\n");
>               return -EINVAL;
>       }
>       data->bus_freq = prop;

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
