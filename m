From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/9] net: dsa: Initialize CPU port ethtool ops
 per tree
Date: Sat, 4 Jun 2016 22:38:55 +0200
Message-ID: <20160604203855.GH2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-11-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59649 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbcFDUi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:38:57 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-11-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> index e8386157de30..938262010524 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -346,7 +346,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
>  			continue;
>  	}
>  
> -	return 0;
> +	return dsa_cpu_port_ethtool_setup(dst, ds);

Hi Florian

This is wrong. Remember, multiple CPU ports. You need to apply this to
each CPU port.

     Andrew
