From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 21:30:53 +0300
Message-ID: <81bb72b5-ccea-ee75-24f9-ffec73853fd9@cogentembedded.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34044 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151AbcFNSa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 14:30:58 -0400
Received: by mail-lf0-f41.google.com with SMTP id j7so86077156lfg.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 11:30:57 -0700 (PDT)
In-Reply-To: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 07:16 PM, Jeremy Linton wrote:

> If the interrupt configuration isn't set and we are using the
> internal phy, then we need to poll the phy to reliably detect
> phy state changes.
>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 8af2556..369dc7d 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -1020,6 +1020,9 @@ static int smsc911x_mii_probe(struct net_device *dev)
>  		return -ENODEV;
>  	}
>
> +	if ((!phydev->irq) && (!pdata->using_extphy))

    Inner parens aren't needed at all.

[...]

MBR, Sergei
