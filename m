From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/6] restructure of_phy_register_fixed_link() for further
 modifications
Date: Thu, 26 Mar 2015 22:01:40 +0300
Message-ID: <55145794.9090608@cogentembedded.com>
References: <55142C31.5050504@list.ru> <55142CB1.1080107@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rosenr@marvell.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:36353 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbbCZTBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 15:01:44 -0400
Received: by lbbug6 with SMTP id ug6so48117048lbb.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 12:01:42 -0700 (PDT)
In-Reply-To: <55142CB1.1080107@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/26/2015 06:58 PM, Stas Sergeev wrote:

> -=-=-=-=-=-=-=-=-=# Don't remove this line #=-=-=-=-=-=-=-=-=-

    Hm, why? You could have put a proper change log here...
    Also, threading the patches one after the other is a bad idea, please post 
them all as a replies to the patchset summary (0/6).

> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
> ---
>   drivers/of/of_mdio.c |   32 ++++++++++++++++++--------------
>   1 file changed, 18 insertions(+), 14 deletions(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 1bd4305..b3dc1e6 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -301,22 +301,26 @@ int of_phy_register_fixed_link(struct device_node *np)
>                                 "asym-pause");
>           of_node_put(fixed_link_node);
>           phy = fixed_phy_register(PHY_POLL, &status, np);
> -        return IS_ERR(phy) ? PTR_ERR(phy) : 0;
> -    }

    Unfortunately, your patch has been whitespace-damaged by your mailer, with 
all tabs converted to spaces.

WBR, Sergei
