From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH net,1/1] hyperv: Add support for setting MAC from within
 guests
Date: Mon, 30 Jul 2012 14:39:27 +0200
Message-ID: <20120730123927.GA29459@aepfle.de>
References: <1341940762-18307-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, kys@microsoft.com,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341940762-18307-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, Haiyang Zhang wrote:

> diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
> index 981ebb1..fbf5394 100644
> --- a/drivers/net/hyperv/rndis_filter.c
> +++ b/drivers/net/hyperv/rndis_filter.c
> @@ -47,6 +48,7 @@ struct rndis_request {
>  	struct hv_page_buffer buf;
>  	/* FIXME: We assumed a fixed size request here. */
>  	struct rndis_message request_msg;
> +	u8 ext[100];

This array is not referenced in the patch.
Please add a comment to the code what the purpose of this array is, and
why its size is 100 bytes.

Thanks.

Olaf
