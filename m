From: Patrick Trantham <patrick.trantham@fuel7.com>
Subject: Re: [PATCH] fix initializer entry defined twice issue
Date: Thu, 06 Dec 2012 17:59:21 -0600
Message-ID: <50C13159.2070901@fuel7.com>
References: <1354835928-617-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Otavio Salvador <otavio@ossystems.com.br>,
	Javier Martinez Canillas <javier@dowhile0.org>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cong Ding <dinggnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fuel7.com ([74.222.0.51]:43593 "EHLO mail.fuel7.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932077Ab2LFX7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 18:59:30 -0500
In-Reply-To: <1354835928-617-1-git-send-email-dinggnu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2012 05:16 PM, Cong Ding wrote:
> the ".config_intr" is defined twice in both line 208 and 212.
>
> Signed-off-by: Cong Ding <dinggnu@gmail.com>
> ---
>   drivers/net/phy/smsc.c |    1 -
>   1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index 16dceed..5cee6bd 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -205,7 +205,6 @@ static struct phy_driver smsc_phy_driver[] = {
>   	/* basic functions */
>   	.config_aneg	= genphy_config_aneg,
>   	.read_status	= lan87xx_read_status,
> -	.config_intr	= smsc_phy_config_intr,
>   
>   	/* IRQ related */
>   	.ack_interrupt	= smsc_phy_ack_interrupt,

Hi Cong,

That looks like a mistake from my previous patch to that file.  Copy and 
paste fail.

The line should read:
.config_init    = smsc_phy_config_init,

I can submit a patch once I get off work unless you beat me to it.

regards,
Patrick
