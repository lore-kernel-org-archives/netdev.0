From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 08/12] net: dsa: b53: Move EEE functions to b53
Date: Mon, 18 Sep 2017 18:27:41 -0400
Message-ID: <87poan1w2q.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-9-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36080 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdIRWbN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:31:13 -0400
In-Reply-To: <20170918214128.27896-9-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> @@ -649,7 +595,7 @@ static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
>  	core_writel(priv, reg, offset);
>  
>  	if (!phydev->is_pseudo_fixed_link)
> -		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
> +		p->eee_enabled = b53_eee_init(ds, port, phydev);
>  }

I know this is a bit out-of-scope of this patch, but I have to say I am
not confortable with having still phy device stuffs in switch drivers...

Can this is_pseudo_fixed_link check + phy_eee_init + eee_enable be moved
up to dsa_slave_adjust_link in a future patch maybe?

Thanks,

        Vivien
