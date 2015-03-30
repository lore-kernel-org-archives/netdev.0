From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bonding: Remove hardcoded initialization
Date: Mon, 30 Mar 2015 10:25:09 -0400
Message-ID: <20150330142447.GK1051@gospo>
References: <1427520871-29869-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35569 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbC3OZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 10:25:36 -0400
Received: by ykeg184 with SMTP id g184so9267659yke.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 07:25:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427520871-29869-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:34:31PM -0700, Mahesh Bandewar wrote:
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

I realize that the changelog would be identical to the title, so
probably not critical here, but please add one whenever possible.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_3ad.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 3cce25818b57..48f3bd7e2350 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -1776,7 +1776,7 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
>  
>  		port->is_enabled = true;
>  		/* private parameters */
> -		port->sm_vars = 0x3;
> +		port->sm_vars = AD_PORT_BEGIN | AD_PORT_LACP_ENABLED;
>  		port->sm_rx_state = 0;
>  		port->sm_rx_timer_counter = 0;
>  		port->sm_periodic_state = 0;
> -- 
> 2.2.0.rc0.207.ga3a616c
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
