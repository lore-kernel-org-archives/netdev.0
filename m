From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/4] net: smsc911x: add support for a reset GPIO
Date: Tue, 23 Jul 2013 21:36:46 +0400
Message-ID: <51EEBF2E.5080604@cogentembedded.com>
References: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de> <1374595924-12338-2-git-send-email-g.liakhovetski@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374595924-12338-2-git-send-email-g.liakhovetski@gmx.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/23/2013 08:12 PM, Guennadi Liakhovetski wrote:

> If a reset GPIO is specified in platform data, take the controller out of
> reset before using it.

    A small typo in the comment...

> Signed-off-by: Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
[...]

> diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
> index 4dde70e..4e3e49d 100644
> --- a/include/linux/smsc911x.h
> +++ b/include/linux/smsc911x.h
> @@ -32,8 +32,18 @@ struct smsc911x_platform_config {
>   	unsigned int shift;
>   	phy_interface_t phy_interface;
>   	unsigned char mac[6];
> +	unsigned int reset_gpio;
> +	unsigned int reset_gpio_config;
>   };
>
> +/*
> + * Bits for platform_device reest GPIO configuration: an OR of any GPIOF_* flags

    s/reest/reset/

WBR, Sergei

