From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH net-next] net: dsa: Remove redundant NULL dst check
Date: Fri, 21 Apr 2017 09:29:44 +0200
Message-ID: <201704210929.45552.jbe@pengutronix.de>
References: <20170420224723.6916-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58399 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1036030AbdDUHaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 03:30:15 -0400
In-Reply-To: <20170420224723.6916-1-f.fainelli@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Friday 21 April 2017 00:47:22 Florian Fainelli wrote:
> tag_lan9303.c does check for a NULL dst but that's already checked by
> dsa_switch_rcv() one layer above.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/dsa/tag_lan9303.c | 5 -----
>  1 file changed, 5 deletions(-)
>
> diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
> index 563b6c8fe445..70130ed5c21a 100644
> --- a/net/dsa/tag_lan9303.c
> +++ b/net/dsa/tag_lan9303.c
> @@ -79,11 +79,6 @@ static struct sk_buff *lan9303_rcv(struct sk_buff
> *skb, struct net_device *dev, struct dsa_switch *ds;
>  	unsigned int source_port;
>
> -	if (unlikely(!dst)) {
> -		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing switch tree device\n");
> -		return NULL; 
> -	}
> -
>  	ds = dst->ds[0];
>
>  	if (unlikely(!ds)) {

Thanks!

Acked-by: Juergen Borleis <jbe@pengutronix.de>

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
