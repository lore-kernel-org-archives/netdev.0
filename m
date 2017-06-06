From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/5] net: dsa: Remove master_netdev and use dst->cpu_dp->netdev
Date: Tue, 06 Jun 2017 13:24:20 -0400
Message-ID: <87d1ahjagr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606170202.21491-1-f.fainelli@gmail.com> <20170606170202.21491-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58226 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751436AbdFFR03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:26:29 -0400
In-Reply-To: <20170606170202.21491-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> -	struct net_device *p = ds->dst[ds->index].master_netdev;
> +	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;

                               ds->dst->cpu_dp->netdev

ds->dst is not an array anymore, lucky sf2 switch index is always 0 ;-)

>  	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
>  	struct ethtool_wolinfo pwol;
>  
> @@ -829,7 +829,7 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
>  static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
>  			      struct ethtool_wolinfo *wol)
>  {
> -	struct net_device *p = ds->dst[ds->index].master_netdev;
> +	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;

same here.

Thanks,

        Vivien
