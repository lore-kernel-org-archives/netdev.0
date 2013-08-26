From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce
 the huawei_cdc_ncm driver
Date: Mon, 26 Aug 2013 16:31:25 -0400 (EDT)
Message-ID: <20130826.163125.1134768821551948034.davem@davemloft.net>
References: <mrkiko.rs@gmail.com>
	<1377244590-8558-1-git-send-email-mrkiko.rs@gmail.com>
	<1377244590-8558-3-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: mrkiko.rs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377244590-8558-3-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Enrico Mioso <mrkiko.rs@gmail.com>
Date: Fri, 23 Aug 2013 09:56:29 +0200

> +	if ((on && atomic_add_return(1, &drvstate->pmcount) == 1) || (!on && atomic_dec_and_test(&drvstate->pmcount))) {

These line significantly exceeds 80 columns.

> +		subdriver = usb_cdc_wdm_register(ctx->control,
> +						 &usbnet_dev->status->desc,
> +						 256, /* CDC-WMC r1.1 requires wMaxCommand to be "at least 256 decimal (0x100)" */
> +						 huawei_cdc_ncm_wdm_manage_power);

Likewise.

> +	if (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->suspend)

Likewise.

> +	int ret = 0;
> +	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
> +	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
> +	bool callsub = (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->resume); /* should we call subdriver's resume? ? */

Likewise, and order local function variable declarations by line
length, longest to shortest.
