From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next] Fix hardcoded ni65 interrupt name to use system device
 value
Date: Sat, 21 Sep 2013 23:48:33 +0400
Message-ID: <523DF811.3010209@cogentembedded.com>
References: <1379791939-23887-1-git-send-email-repkam09@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Repka <repkam09@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:54674 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab3IUTsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 15:48:31 -0400
Received: by mail-la0-f47.google.com with SMTP id eo20so1357351lab.20
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 12:48:29 -0700 (PDT)
In-Reply-To: <1379791939-23887-1-git-send-email-repkam09@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/21/2013 11:32 PM, Mark Repka wrote:

> The ni65 interrupt handler was using the hard-coded name which would make it difficult to tell where the interrupt came from. Changed to use the device name that made the interrupt.

    Please wrap your changelog lines at 80 columns (preferably even less).

> Signed-off-by: Mark Repka <repkam09@gmail.com>
> ---
>   drivers/net/ethernet/amd/ni65.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
> index 1cf33ad..00cb6db 100644
> --- a/drivers/net/ethernet/amd/ni65.c
> +++ b/drivers/net/ethernet/amd/ni65.c
> @@ -295,7 +295,7 @@ static int ni65_open(struct net_device *dev)
>   {
>   	struct priv *p = dev->ml_priv;
>   	int irqval = request_irq(dev->irq, ni65_interrupt,0,
> -                        cards[p->cardno].cardname,dev);
> +                       dev->name,dev);

    Don't indent with all spaces, use tabs at the start of line. And start the 
line under 'dev->irq' please.

WBR, Sergei
