From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 4/4] net: phy: realtek: cleanup code
Date: Fri, 10 May 2013 15:18:28 +0400
Message-ID: <518CD784.1030709@cogentembedded.com>
References: <201305081910.27203.neidhard.kim@lge.com> <1368170967-20589-4-git-send-email-neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: r58129@freescale.com, davem@davemloft.net, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, timur@freescale.com,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jongsung Kim <neidhard.kim@lge.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:63260 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab3EJLSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 07:18:24 -0400
Received: by mail-lb0-f177.google.com with SMTP id 13so4093493lba.36
        for <netdev@vger.kernel.org>; Fri, 10 May 2013 04:18:23 -0700 (PDT)
In-Reply-To: <1368170967-20589-4-git-send-email-neidhard.kim@lge.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-05-2013 11:29, Jongsung Kim wrote:

> This patch cleans up the drivers code by:

> - using a consistent way to reference functions
> - removing unused macro-definitions
> - removing unnecessary new-lines
> - making ack_interrupt functions shorter.

> Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
> ---
>   drivers/net/phy/realtek.c |   29 ++++++++++-------------------
>   1 files changed, 10 insertions(+), 19 deletions(-)

> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
> index 6f0726a..fd09844 100644
> --- a/drivers/net/phy/realtek.c
> +++ b/drivers/net/phy/realtek.c
[...]
> @@ -112,8 +103,8 @@ static struct phy_driver realtek_drv[] = {
>   		.read_status	= &genphy_read_status,
>   		.ack_interrupt	= &rtl8201f_ack_interrupt,
>   		.config_intr	= &rtl8201f_config_intr,
> -		.suspend	= genphy_suspend,
> -		.resume		= genphy_resume,
> +		.suspend	= &genphy_suspend,
> +		.resume		= &genphy_resume,

    Contrariwise, you should have dropped & from the other functions. 
It's completely superfluous.

WBR, Sergei
