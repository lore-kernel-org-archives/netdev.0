From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH net-next] bcm87xx: Add MODULE_DEVICE_TABLE
Date: Tue, 03 Sep 2013 10:32:02 -0700
Message-ID: <52261D12.5000009@gmail.com>
References: <1378071184.25743.52.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:63184 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735Ab3ICRcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 13:32:05 -0400
Received: by mail-ob0-f177.google.com with SMTP id f8so6097760obp.22
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 10:32:04 -0700 (PDT)
In-Reply-To: <1378071184.25743.52.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2013 02:33 PM, Ben Hutchings wrote:
> bcm87xx currently isn't auto-loaded if built as a module.
>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> Compile-tested only.

Then how do you know that it does anything sensible?

Other than that, it seems plausible.

David Daney

>
> Ben.
>
>   drivers/net/phy/bcm87xx.c | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
> index 7997895..f5b44ff 100644
> --- a/drivers/net/phy/bcm87xx.c
> +++ b/drivers/net/phy/bcm87xx.c
> @@ -230,4 +230,11 @@ static void __exit bcm87xx_exit(void)
>   }
>   module_exit(bcm87xx_exit);
>
> +static struct mdio_device_id __maybe_unused bcm87xx_tbl[] = {
> +	{ PHY_ID_BCM8706, 0xffffffff },
> +	{ PHY_ID_BCM8727, 0xffffffff },
> +	{ }
> +};
> +
>   MODULE_LICENSE("GPL");
> +MODULE_DEVICE_TABLE(mdio, bcm87xx_tbl);
>
