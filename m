From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
 driver name
Date: Wed, 7 Mar 2012 21:17:46 +0100
Message-ID: <20120307201746.GA20900@aepfle.de>
References: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Haiyang Zhang <haiyangz@microsoft.com>, kys@microsoft.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, Haiyang Zhang wrote:


> @@ -482,7 +484,7 @@ MODULE_DEVICE_TABLE(vmbus, id_table);
>  
>  /* The one and only one */
>  static struct  hv_driver netvsc_drv = {
> -	.name = "netvsc",
> +	.name = MODULE_NAME,

It would be nice if this could be applied to 3.3.
hv_storvsc and hid-hyperv already use the same naming, this patch was
send last year already but was not applied for some reason.

Olaf
